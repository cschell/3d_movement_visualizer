#!/usr/bin/env ruby

require "json"
require "rmagick"

# Here I'm mapping relevant input data to its features, so we know what belongs together
features = {
  "Relative Position Left Hand"   => 0..2,
  "Relative Position right Hand"  => 3..5,
  "Velocity Left Hand"            => 6..8,
  "Velocity Right Hand"           => 9..11,

  "Angle Right Elbow"             => 21,
  "Distance Change Between Hands" => 22
}

@column_width = 20

# Get input data
gesture_data_sets = JSON.parse(File.read('./example_data/data.json'))

# Loop over each gesture
gesture_data_sets.each do |gesture, data_sets|
  gestureImage = Magick::Image.new(features.size * @column_width, data_sets.size)

  # Loop over each gesture's data sets
  data_sets.each_with_index do |data_set, row_index|
    col_index = 0

    # Loop over each feature
    features.each do |desc, data_indices|
      # Get values for red, greem and blue
      color = 3.times.map do |i|
        data_index = Array(data_indices).rotate(i).first

        # Our data are between -1 and 1 most of the time, but can be higher
        # often enough – that's why I'm cheating here a bit and multiply only by
        # half of 255. This line may vary depending on your data anyhow, so just
        # make sure you get values for `converted_value` between 0 and 255
        converted_value = (data_set[data_index] + 1) * (255/2) / 2
        [converted_value , 255].min
      end

      rgb_color_string = "rgb(#{color.join(",")})"

      # Repeat the coloring, depending on how thick you like your columns
      @column_width.times do
        # Set the color of the current pixel
        gestureImage = gestureImage.color_point(col_index, row_index, rgb_color_string)
        col_index += 1
      end
    end
  end

  gestureImage.write(gesture + ".png")
end
