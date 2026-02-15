require "versalog"

log = Versalog::VersaLog.new(
  enum: "detailed",
  tag: "BATCH",
  show_file: false,
  show_tag: true,
  enable_all: false,
  notice: false,
  all_save: true,
  save_levels: ["INFO", "ERROR"],
  silent: false
)

total_files = 3

log.info("Batch Start")

log.timer("Total Batch") do
  (1..total_files).each do |file_index|
    
    log.step("Processing file_#{file_index}.txt", file_index, total_files)

    log.timer("file_#{file_index}.txt") do
      total_lines = 10

      (1..total_lines).each do |i|
        sleep 0.1
        log.progress("file_#{file_index}.txt", i, total_lines)
      end
    end

    log.progress("Overall Progress", file_index, total_files)
  end
end

log.info("Batch Finished")
