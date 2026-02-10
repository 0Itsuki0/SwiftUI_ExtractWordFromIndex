
import NaturalLanguage
import SwiftUI

struct WordFromIndexDemo: View {
    private let text = "This is a test."

    @State private var selection: TextSelection?

    private var index: String.Index? {
        guard let selection else {
            return nil
        }
        switch selection.indices {
        case .selection(let range):
            return range.lowerBound
        case .multiSelection(let rangeSet):
            return rangeSet.ranges.first?.lowerBound
        @unknown default:
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 36) {
                TextField("", text: .constant(text), selection: $selection)
                    .font(.headline)
                Divider()

                if let index {
                    Text(
                        String(
                            "Word for index: \(index.intOffset(in: self.text))"
                        )
                    )
                    .font(.headline)

                    Text(
                        String(
                            "With NLTagger: \(self.text.wordAtIndexWithNLTagger(index))"
                        )
                    )
                    Text(
                        String(
                            "With UITextField(View): \(self.text.wordAtIndexWithUITextView(index))"
                        )
                    )

                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow.opacity(0.1))
            .navigationTitle("Word From Index")

        }

    }

}

extension String.Index {
    init?(index: Int, in string: String) {
        if index < 0 {
            return nil
        }
        if index > string.count {
            return nil
        }
        self = string.index(string.startIndex, offsetBy: index)
    }

    func intOffset(in string: String) -> Int {
        return string.distance(from: string.startIndex, to: self)
    }
}

extension String {
    func wordAtIndexWithNLTagger(_ index: String.Index) -> String? {
        let tagger = NLTagger(tagSchemes: [])
        tagger.string = self
        let tag = tagger.tokenRange(at: index, unit: .word)
        return String(self[tag])
    }

    func wordAtIndexWithUITextView(_ index: String.Index) -> String? {
        // or UITextField
        let textView: UITextView = UITextView()
        textView.text = self

        let offset = index.intOffset(in: self)

        guard
            let position = textView.position(
                from: textView.beginningOfDocument,
                offset: offset
            )
        else {
            return nil
        }

        guard
            let wordRange = textView.tokenizer.rangeEnclosingPosition(
                position,
                with: .word,
                inDirection: .layout(.right)
            )
        else { return nil }

        return textView.text(in: wordRange)
    }
}
