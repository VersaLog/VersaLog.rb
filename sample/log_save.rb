require "versalog"

# show_file False
logger = Versalog::VersaLog.new(
    enum: "detailed",
    all_save: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")