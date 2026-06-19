// Services/PowerProfile.qml
//
// Stub for power-profiles-daemon integration. The Quickshell upstream
// does not ship a `Quickshell.Services.PowerProfile` module (the
// daemon is exposed only over D-Bus), so we expose the same public
// API shape (`current`, `profiles`, `setProfile`, `next`) that
// `Modules/PowerProfile.qml` consumes, with a safe default of
// "balanced". Once a D-Bus binding is added (TODO), the singleton's
// properties will reactively update.
//
// D-Bus reference (power-profiles-daemon):
//   bus:        org.freedesktop.DBus
//   name:       net.hadess.PowerProfiles
//   path:       /net/hadess/PowerProfiles
//   interface:  net.hadess.PowerProfiles
//   properties: ActiveProfile, Profiles (a(ss))
//   methods:    HoldProfile (s), ReleaseProfile ()

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Hardcoded profiles per the power-profiles-daemon spec.
    // Order matches `powerprofilesctl list` output: performance,
    // balanced, power-saver.
    readonly property var profiles: ["performance", "balanced", "power-saver"]

    // The currently active profile. Until we wire up D-Bus, default
    // to "balanced" so the module renders a stable icon.
    property string current: "balanced"

    function setProfile(p) {
        if (profiles.indexOf(p) < 0) return;
        current = p;
        // TODO: send D-Bus call to net.hadess.PowerProfiles on
        // path /net/hadess/PowerProfiles to set
        // `net.hadess.PowerProfiles.ActiveProfile` to `p`.
    }

    function next() {
        var i = profiles.indexOf(current);
        if (i < 0) i = 0;
        setProfile(profiles[(i + 1) % profiles.length]);
    }
}
