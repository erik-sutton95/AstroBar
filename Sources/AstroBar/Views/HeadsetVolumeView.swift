import AstroBarCore
import SwiftUI

/// Controls for the A50 X / A50 Gen 5: the headset's own master volume, the
/// game/voice mix it reports, and whether the Mac's volume keys are routed to it.
struct HeadsetVolumeView: View {
    let monitor: A50Monitor

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 9) {
                SectionLabel(title: "Headset", systemImage: "headphones")

                LabeledSlider(
                    title: "Volume",
                    range: Double(A50X.volumeRange.lowerBound) ... Double(A50X.volumeRange.upperBound),
                    step: 1,
                    value: Binding(
                        get: { monitor.headsetVolume },
                        set: { monitor.headsetVolume = $0 }),
                    valueLabel: { Self.percentLabel(Int($0.rounded())) },
                    onCommit: { _ in monitor.commitHeadsetVolume() })
                    .help("The headset's own volume, the same level its wheel changes.")

                if let mix = monitor.chatMix {
                    HStack {
                        Text("Game / Voice").font(.callout)
                        Spacer()
                        Text(Self.mixLabel(mix))
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .help("Set with the Game and Voice buttons on the headset.")
                }

                Divider()

                volumeKeys
            }
        }
    }

    @ViewBuilder
    private var volumeKeys: some View {
        if monitor.volumeKeysActive {
            Label("Volume keys control the headset", systemImage: "keyboard")
                .font(.caption)
                .foregroundStyle(.secondary)
                .help("Applies while the A50 is the Mac's sound output.")
        } else {
            HStack {
                Label("Volume keys need Accessibility access", systemImage: "keyboard")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Allow…") { monitor.requestVolumeKeyPermission() }
                    .controlSize(.small)
            }
        }
    }

    /// The wheel has 22 positions; shown as a percentage like the macOS slider.
    static func percentLabel(_ level: Int) -> String {
        let percent = Double(level) / Double(A50X.volumeRange.upperBound) * 100
        return "\(Int(percent.rounded()))%"
    }

    /// `"50/50"`, game share first.
    static func mixLabel(_ raw: Int) -> String {
        let game = Int((Double(raw) / Double(A50X.chatMixRange.upperBound) * 100).rounded())
        return "\(game)/\(100 - game)"
    }
}
