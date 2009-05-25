#!/usr/bin/ruby

# Dropzone Destination Info
# Name: Move Files
# Description: Allows you to move dropped files to a specified folder.
# Handles: NSFilenamesPboardType
# Creator: Aptonic Software
# URL: http://aptonic.com
# OptionsNIB: ChooseFolder

def dragged
  $dz.determinate("1")
  
  move = true
  
  if ENV['OPERATION'] == "NSDragOperationCopy"
    operation = "Copying"
    move = false
  else
    operation = "Moving"
  end
  
  $dz.begin("#{operation} files...")

  Rsync.do_copy($dz, $items, ENV['EXTRA_PATH'], move)

  if move
    # Recursively delete empty directories
    $items.each do |dir|
      if File.directory?(dir)
        Dir.chdir dir do
          `find . -type d -print0 2>&1 | xargs -0 rmdir -p 2>/dev/null`
          `rmdir \"#{dir}\" 2>/dev/null`
        end
      end
    end
  end
  
  finish_op = (move ? "Move" : "Copy")
  $dz.finish("#{finish_op} Complete")
  $dz.url("0")
end

def clicked
  system("open \"#{ENV['EXTRA_PATH']}\"")
end