require "versalog"

logger = Versalog::VersaLog.new(
    enum: "file",
    show_file: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")