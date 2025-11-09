# Contributing to BUFLO

Thank you for your interest in contributing to BUFLO!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/Buflo.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes: `lua test_parser.lua`
6. Commit with a descriptive message: `git commit -m "Add feature: your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Code Style

- Use 2 spaces for indentation
- Keep functions focused and small
- Add comments for complex logic
- Follow existing naming conventions (snake_case for variables/functions)

## Testing

Before submitting a PR:
- Run `lua test_parser.lua` - ensure all parser tests pass
- Run `lua test_buflo_gui.lua` - test GUI functionality
- Test manually with `lua buflo.lua`

## Areas to Contribute

- Additional field types
- More template helpers (@qrcode, @barcode, etc.)
- Enhanced syntax highlighting
- Undo/redo in editor
- Search/replace functionality
- PDF generation improvements
- Batch mode enhancements
- Documentation improvements

## Questions?

Open an issue for discussion before starting major work.
