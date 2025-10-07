require "versalog"

# show_file False
logger = Versalog::VersaLog.new(
    enum: "simple"
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# show_file True
logger = Versalog::VersaLog.new(
    enum: "simple",
    show_file: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# show_tag True
logger = Versalog::VersaLog.new(
    enum: "simple",
    show_tag: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# notice True
logger = Versalog::VersaLog.new(
    enum: "simple",
    notice: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# silent True
logger = Versalog::VersaLog.new(
    enum: "simple",
    silent: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# enable_all True
logger = Versalog::VersaLog.new(
    enum: "simple",
    enable_all: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")