$n = -join ((0,1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f')|get-random -count 6)
$p = (get-location).path|out-file C:\windows\system32\rcwm\mv\$n -encoding UTF8 -NoNewline
