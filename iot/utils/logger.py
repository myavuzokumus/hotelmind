import logging


def setup_logger(name="SmartRoom", level=logging.DEBUG):
    """Uygulama için logger ayarlar"""

    # Ana logger'ı yapılandır
    logger = logging.getLogger(name)
    logger.setLevel(level)

    # Konsol handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(level)

    # Format
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(formatter)

    # Logger'a handler ekle
    logger.addHandler(console_handler)

    return logger


# AWS IoT Client için logger
def setup_aws_iot_logger():
    """AWS IoT için logger ayarlar"""
    logger = logging.getLogger("AWSIoTPythonSDKv2")
    logger.setLevel(logging.DEBUG)

    # Konsol handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)

    # Format
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(formatter)

    # Logger'a handler ekle
    logger.addHandler(console_handler)

    return logger