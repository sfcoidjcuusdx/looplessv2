import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    /// Custom mindfulness quotes
    let quotes = [
        "You don’t need this right now — your mind is asking for stillness.",
        "Every scroll is a choice. Choose presence.",
        "Growth happens in quiet moments.",
        "Pause. Reflect. Reconnect with your values.",
        "This urge will pass — like all things do.",
        "You deserve to be intentional, not impulsive.",
        "Step back. Breathe. What truly matters?",
        "Loops break when awareness begins."
    ]

    /// Rotating supportive lines (beneath the quote)
    let supportMessages = [
        "Take a breath. You’re in control.",
        "Let’s redirect your energy with purpose.",
        "Your goals matter more than this momentary urge.",
        "It only takes one pause to reclaim your day.",
        "Discomfort is temporary. Clarity is lasting.",
        "You're doing better than you think."
    ]

    /// Pick random quote and support message
    var randomQuote: String {
        quotes.randomElement() ?? "Time to refocus."
    }

    var randomSupport: String {
        supportMessages.randomElement() ?? ""
    }

    /// Builds a unified label for subtitle with quote and message stacked
    func styledSubtitle() -> ShieldConfiguration.Label {
        let combined = """
        \(randomQuote)

        \(randomSupport)
        """
        return ShieldConfiguration.Label(
            text: combined,
            color: .lightGray
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor.black,
            icon: UIImage(systemName: "lock.shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Hold Up ✋",
                color: .white
            ),
            subtitle: styledSubtitle(),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Reflect Instead",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemTeal,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: UIColor.black,
            icon: UIImage(systemName: "apps.iphone"),
            title: ShieldConfiguration.Label(
                text: "Stay Intentional",
                color: .white
            ),
            subtitle: styledSubtitle(),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Reflect Instead",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemIndigo,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor.black,
            icon: UIImage(systemName: "globe"),
            title: ShieldConfiguration.Label(
                text: "Not Right Now",
                color: .white
            ),
            subtitle: styledSubtitle(),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Reflect Instead",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemPurple,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterialDark,
            backgroundColor: UIColor.black,
            icon: UIImage(systemName: "network.slash"),
            title: ShieldConfiguration.Label(
                text: "Mindful Moment",
                color: .white
            ),
            subtitle: styledSubtitle(),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Reflect Instead",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue,
            secondaryButtonLabel: nil
        )
    }
}

