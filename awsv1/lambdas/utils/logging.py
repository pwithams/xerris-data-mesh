"""
Logging object creator
"""
import logging

LOG_MESSAGE_FORMAT: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"


def get_logger(module_name: str, logging_level: str, log_file_name: str = "") -> logging.Logger:
    """
    Ensures the same logging object for each module is returned.

    Args:
        module_name: used to find an existing logger if already created.
        logging_level: a string matching a level, such as DEBUG, INFO, etc.
        log_file_name: if provided, logs will also be written to a file.
    Returns:
        An existing or new Logger object matching the module name.
    """
    logger: logging.Logger = logging.getLogger(module_name)
    if not logger.handlers:
        logger.setLevel(logging_level)
        logger.propagate = False
        formatter = logging.Formatter(LOG_MESSAGE_FORMAT)
        console_handler: logging.StreamHandler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)

        if log_file_name:
            file_handler: logging.FileHandler = logging.FileHandler(log_file_name)
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)

    return logger
