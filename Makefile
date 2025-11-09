.PHONY: help test gui batch clean install

help:
	@echo "BUFLO - Billing Unified Flow Language & Orchestrator"
	@echo ""
	@echo "Available targets:"
	@echo "  make test         - Run all unit tests"
	@echo "  make gui          - Launch GUI with example profile"
	@echo "  make batch        - Run batch processing with example data"
	@echo "  make clean        - Remove generated PDFs and temp files"
	@echo "  make install      - Show installation instructions"
	@echo ""

test:
	@echo "Running BUFLO test suite..."
	@lua buflo/tests/run_all.lua

gui:
	@echo "Launching BUFLO GUI..."
	@lua buflo.lua profiles/example_invoice.bpl.lua

batch:
	@echo "Running batch processing..."
	@lua buflo.lua profiles/example_invoice.bpl.lua --batch --verbose

clean:
	@echo "Cleaning generated files..."
	@rm -rf out/*.pdf
	@rm -f /tmp/buflo_*
	@echo "Done."

install:
	@echo "BUFLO Installation Instructions"
	@echo "================================"
	@echo ""
	@echo "Fedora/RHEL:"
	@echo "  sudo dnf install lua wkhtmltopdf qpdf"
	@echo ""
	@echo "Debian/Ubuntu:"
	@echo "  sudo apt install lua5.4 wkhtmltopdf qpdf"
	@echo ""
	@echo "IUP (for GUI mode):"
	@echo "  Download from: https://sourceforge.net/projects/iup/files/"
	@echo "  Or: luarocks install iuplua"
	@echo ""
	@echo "Verify installation:"
	@echo "  make test"
	@echo ""
