/*
 * Why a purchase can be quiet, and what this does about it.
 *
 * The client announces a learned spell from its own handler for SMSG_LEARNED_SPELL, and that
 * handler asks one question first: does the row its SpellCustomAttr table holds for this spell
 * carry bit 0x400 of the third attribute dword? If it does, the client fires
 * NOTABLE_SPELL_LEARNED, which is the event ToasTNotificationSystem draws the "New Spell
 * Learned" toast and plays the sound from. If it does not, the client checks whether the spell
 * is marked hidden and otherwise fires nothing at all - which is how a purchase from a book can
 * produce the trainer's chat line and no announcement.
 *
 * That table is patchable over the wire: the client's Extensions.dll registers a handler for its
 * "SMSG_PATCH_SPELL_CUSTOM_ATTR" opcode that reads one row of 0x2C bytes - the row id, the spell
 * id, then nine attribute dwords, exactly as the table holds them - and either updates the row
 * with that id or adds a new one, then rebuilds the spell id index the announce check reads.
 * The row's other fields are copied from the table itself (see SpellbookNotifyData.h), so the
 * only thing this ever changes about a spell is that one bit.
 *
 * The table has no row at all for some of the spells the books sell; those get a row of their
 * own on an id past the table's last, followed by one unchanged copy of the table's first row,
 * because the client only rebuilds that index when a push updates a row it already holds.
 */

#include "Configuration/Config.h"
#include "Log.h"
#include "Player.h"
#include "World.h"
#include "WorldPacket.h"
#include "WorldSession.h"
#include "SpellbookNotifyData.h"
#include "spellbook_api.h"
#include "spellbook_notify.h"

#include <algorithm>
#include <fstream>
#include <iterator>
#include <unordered_map>
#include <vector>

namespace
{
    /// The wire number lives with the module's public surface (spellbook_api.h); this file is
    /// the one that sends it, and the test driver is the one that watches for it.
    using Spellbook::SMSG_PATCH_SPELL_CUSTOM_ATTR;

    constexpr char const *ENABLE_KEY = "Spellbook.Notify.Enable";

    /// The bit of the third attribute dword the client's learn handler tests before it announces.
    constexpr uint32 NOTABLE_BIT = 0x400;

    /// The bit of the fourth attribute dword that makes Extensions.dll mute the learn handler's chat lines.
    constexpr uint32 QUIET_LEARN_BIT = 0x40000;

    /// A row as the client's reader consumes it: eleven dwords, no length prefix, no count.
    constexpr std::size_t ROW_FIELDS = 11;
    constexpr std::size_t ROW_BYTES = ROW_FIELDS * sizeof(uint32);

    void SendRow(Player *player, SpellbookNotifyData::Row const &row)
    {
        uint32 const fields[ROW_FIELDS] = {row.RowId, row.SpellId, row.Field2, row.Field3,
                                           row.Field4, row.Field5, row.Field6, row.Field7,
                                           row.Field8, row.Field9, row.Field10};
        WorldPacket packet(SMSG_PATCH_SPELL_CUSTOM_ATTR, ROW_BYTES);
        packet.append(reinterpret_cast<uint8 const *>(fields), ROW_BYTES);
        player->SendDirectMessage(&packet);
    }

    /// A row whose id is one of ours rather than the table's: the client adds it instead of
    /// updating an existing one, and the index rebuild has to be asked for separately.
    bool AddsRow(SpellbookNotifyData::Row const &row)
    {
        return row.RowId >= SpellbookNotifyData::FIRST_FRESH_ROW_ID;
    }

    /// Every row of the client's SpellCustomAttr table, read once from the server's copy of it, which is the
    /// same file; the book's own table only covers the spells a book sells.
    std::unordered_map<uint32, SpellbookNotifyData::Row> LoadTableRows()
    {
        std::unordered_map<uint32, SpellbookNotifyData::Row> rows;
        std::string const path = sWorld->GetDataPath() + "dbc/SpellCustomAttr.dbc";
        std::ifstream file(path, std::ios::binary);
        std::vector<char> const data((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        uint32 header[5] = {};
        if (data.size() >= sizeof(header))
            std::copy_n(data.begin(), sizeof(header), reinterpret_cast<char *>(header));
        uint32 const count = header[1];
        bool const valid = data.size() >= sizeof(header) && header[0] == 0x43424457 && header[2] == ROW_FIELDS &&
                           header[3] == ROW_BYTES && data.size() >= sizeof(header) + std::size_t(count) * ROW_BYTES;
        if (!valid)
        {
            LOG_WARN("module.spellbook", "{} is missing or not the client's SpellCustomAttr table; temporary spells "
                     "outside the books are learned with their chat line", path);
            return rows;
        }
        for (uint32 index = 0; index < count; ++index)
        {
            uint32 fields[ROW_FIELDS];
            std::copy_n(data.begin() + sizeof(header) + std::size_t(index) * ROW_BYTES, ROW_BYTES,
                        reinterpret_cast<char *>(fields));
            rows.emplace(fields[1], SpellbookNotifyData::Row{fields[1], fields[0], fields[2], fields[3], fields[4],
                                                             fields[5], fields[6], fields[7], fields[8], fields[9],
                                                             fields[10]});
        }
        LOG_INFO("module.spellbook", "Read {} SpellCustomAttr rows from {}", rows.size(), path);
        return rows;
    }

    SpellbookNotifyData::Row const *FindTableRow(uint32 spellId)
    {
        static std::unordered_map<uint32, SpellbookNotifyData::Row> const rows = LoadTableRows();
        auto const found = rows.find(spellId);
        return found == rows.end() ? nullptr : &found->second;
    }

    SpellbookNotifyData::Row const *FindRow(uint32 spellId)
    {
        auto const &rows = SpellbookNotifyData::Rows;
        auto const found = std::lower_bound(rows.begin(), rows.end(), spellId,
            [](SpellbookNotifyData::Row const &row, uint32 id) { return row.SpellId < id; });

        if (found == rows.end() || found->SpellId != spellId)
            return nullptr;

        return &*found;
    }
}

namespace SpellbookNotify
{
    bool Enabled()
    {
        return sConfigMgr->GetOption<bool>(ENABLE_KEY, true);
    }

    void Push(Player *player, uint32 spellId)
    {
        if (!player || !player->GetSession() || !Enabled())
            return;

        SpellbookNotifyData::Row const *row = FindRow(spellId);
        if (!row)
            return;

        SendRow(player, *row);

        if (AddsRow(*row))
            SendRow(player, SpellbookNotifyData::RefreshRow);

        LOG_DEBUG("module.spellbook", "Pushed the SpellCustomAttr row for {} (row {}, {}) to {}",
                  spellId, row->RowId, AddsRow(*row) ? "added" : "updated", player->GetName());
    }

    void Push(Player *player, std::vector<uint32> const &spellIds)
    {
        for (uint32 spellId : spellIds)
            Push(player, spellId);
    }

    void Quiet(Player *player, uint32 spellId)
    {
        if (!player || !player->GetSession())
            return;

        SpellbookNotifyData::Row const *row = FindRow(spellId);
        if (!row)
            row = FindTableRow(spellId);
        if (!row)
            return;

        SpellbookNotifyData::Row quiet = *row;
        quiet.Field5 |= QUIET_LEARN_BIT;
        quiet.Field4 &= ~NOTABLE_BIT;
        SendRow(player, quiet);

        if (AddsRow(*row))
            SendRow(player, SpellbookNotifyData::RefreshRow);
    }

    void Unquiet(Player *player, uint32 spellId)
    {
        if (!player || !player->GetSession())
            return;

        SpellbookNotifyData::Row const *row = FindRow(spellId);
        if (!row)
            row = FindTableRow(spellId);
        if (!row)
            return;

        SendRow(player, *row);

        if (AddsRow(*row))
            SendRow(player, SpellbookNotifyData::RefreshRow);
    }

    void Mute(Player *player, uint32 spellId)
    {
        if (!player || !player->GetSession() || !Enabled())
            return;

        SpellbookNotifyData::Row const *row = FindRow(spellId);
        if (!row || !(row->Field4 & NOTABLE_BIT))
            return;

        SpellbookNotifyData::Row muted = *row;
        muted.Field4 &= ~NOTABLE_BIT;
        SendRow(player, muted);

        if (AddsRow(*row))
            SendRow(player, SpellbookNotifyData::RefreshRow);
    }
}
