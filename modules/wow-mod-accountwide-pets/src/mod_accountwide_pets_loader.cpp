/*
 * mod-accountwide-pets loader.
 *
 * AzerothCore looks up a loader symbol derived from the module's folder name.
 * Vendored under folder "wow-mod-accountwide-pets", so the auto-generated call is
 * "Addwow_mod_accountwide_petsScripts" (every "-" in the folder name becomes "_").
 * Renamed from upstream "Addmod_accountwide_petsScripts" to match this folder name.
 *
 * Released under the GNU AGPL v3, like mod-accountwide.
 */

void AddAccountWidePetsScripts();

void Addwow_mod_accountwide_petsScripts()
{
    AddAccountWidePetsScripts();
}
