def count_between(arr, low, high)
  counter = 0

  arr.each do |element|
    if (element >= low && element <= high)
      counter++
    end
  end
  
  return counter
end