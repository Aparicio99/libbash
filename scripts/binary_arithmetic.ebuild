FOO001="$((0 || -2))"
FOO002="$((0 || 0))"
FOO003="$((-1 && 10))"
FOO004="$((-1 && 0))"
FOO005="$((1 | 2))"
FOO006="$((4 & 2))"
FOO007="$((5 ^ 10))"
FOO008="$((5 <= 5))"
FOO009="$((5 <= -10))"
FOO010="$((5 >= 5))"
FOO011="$((-5 >= 5))"
FOO012="$((5 < 6))"
FOO013="$((-5 < -5))"
FOO014="$((5 > 4))"
FOO015="$((-5 > -5))"
FOO016="$((-5 << 2))"
FOO017="$((-5 >> 2))"
FOO018="$((1 + 1))"
FOO019="$((10 - 5))"
FOO020="$((10 * 5))"
FOO021="$((10 / 4))"
FOO022="$((10 % 4))"
FOO023="$((10 ** 4))"
FOO024="$((!10))"
FOO025="$((~   10))"
FOO026="$((1?10:5))"
FOO027="$((0?10:5))"
value="$((100))"
FOO028="$((++value))"
FOO029="$((--value))"
FOO030="$((value++))"
FOO031="$((value--))"
value="$((100))"
FOO032="$((value+++value++))"
FOO033="$((++value+value++))"
FOO034="$((10*(2+5)<<3%2**5))"
FOO035="$((10*${value}<<3%2**5))"
FOO036="$(( (20&5|3||1*100-20&5*10)+~(2*5) ))"
value="$((100))"