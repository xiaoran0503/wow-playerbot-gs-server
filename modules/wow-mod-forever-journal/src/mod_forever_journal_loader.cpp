/*
 * mod-forever-journal loader.
 *
 * AzerothCore looks up a loader symbol derived from the module's folder name.
 * Vendored under folder "wow-mod-forever-journal", so the auto-generated call is
 * "Addwow_mod_forever_journalScripts" (every "-" in the folder name becomes "_").
 * Renamed from upstream "Addmod_forever_journalScripts" to match this folder name.
 *
 * Released under the MIT License.
 */

void AddJournalScripts();

void Addwow_mod_forever_journalScripts()
{
    AddJournalScripts();
}
