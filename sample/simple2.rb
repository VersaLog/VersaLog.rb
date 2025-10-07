require "versalog"

# show_file False
logger = Versalog::VersaLog.new(
    enum: "simple2"
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# show_file True
logger = Versalog::VersaLog.new(
    enum: "simple2",
    show_file: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# show_tag True
logger = Versalog::VersaLog.new(
    enum: "simple2",
    show_tag: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# notice True
logger = Versalog::VersaLog.new(
    enum: "simple2",
    notice: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# silent True
logger = Versalog::VersaLog.new(
    enum: "simple2",
    silent: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")

# enable_all True
logger = Versalog::VersaLog.new(
    enum: "simple2",
    enable_all: true
)

logger.info("ok")
logger.error("err")
logger.warning("war")
logger.debug("deb")
logger.critical("cri")