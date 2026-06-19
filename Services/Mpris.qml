// Services/Mpris.qml
// Wrapper over Quickshell.Services.Mpris.Mpris. Exposes players and
// play/pause/next/prev helpers. Clean teardown per FR-037.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: {
        if (!Mpris) return [];
        return Mpris.players || [];
    }

    readonly property var activePlayer: {
        if (!Mpris) return null;
        // Mpris exposes `activePlayer` (singular) on the wrapper in
        // recent Quickshell; fall back to first player if not.
        if (Mpris.activePlayer) return Mpris.activePlayer;
        return (players.length > 0) ? players[0] : null;
    }

    function playPause() {
        if (activePlayer && activePlayer.playPause) activePlayer.playPause();
    }
    function next() {
        if (activePlayer && activePlayer.next) activePlayer.next();
    }
    function prev() {
        if (activePlayer && activePlayer.previous) activePlayer.previous();
    }
}
