import argparse
import logging
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)


def parse_cli() -> argparse.Namespace:
    """Console script for newone."""
    parser = argparse.ArgumentParser(prog="newone")
    parser.add_argument("--verbose", help="Log verbosely", action="store_true")
    parser.add_argument("--log", help="Store log files", type=Path)
    parser.set_defaults(func=parser.print_help)
    args = parser.parse_args()

    log_kwargs: dict[str, Any] = {
        "level": logging.DEBUG if args.verbose else logging.INFO
    }
    if args.log:
        log_kwargs["filename"] = args.log
    logging.basicConfig(**log_kwargs)
    return args
def main() -> None:
    logger.debug(f"Launched {__name__}")
    args = parse_cli()
    logger.debug(f"CLI args: {args}")


if __name__ == "__main__":
    main()
