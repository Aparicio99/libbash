ARRAY=(1 2 3 4 5)
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
FOO035="$((10*value<<3%2**5))"
FOO036="$(( (20&5|3||1*100-20&5*10)+~(2*5) ))"
FOO037="$((ARRAY[0]++))"
FOO038="$((++ARRAY[0]))"
FOO039="$((ARRAY[0]--))"
FOO040="$((--ARRAY[0]))"
FOO041="$((ARRAY[8]=9))"
FOO042="$((ARRAY[8]*=10))"
FOO043="$((ARRAY[8]/=10))"
FOO044="$((ARRAY[8]%=2))"
FOO045="$((ARRAY[8]+=8))"
FOO046="$((ARRAY[8]-=0))"
FOO047="$((ARRAY[8]<<=1))"
FOO048="$((ARRAY[8]>>=1))"
FOO049="$((ARRAY[8]&=5))"
FOO050="$((ARRAY[8]|=10))"
FOO051="$((ARRAY[8]^=3))"
PARTIAL[8]=5
FOO052="$((PARTIAL[8]*=1))"
FOO053="$((${#ARRAY[@]}))"
FOO054="$((${ARRAY[5]:-10}))"
FOO055="$((${ARRAY:0}))"
value=100
FOO056="value"
FOO057="$((${FOO056}++))"
FOO058="$((${FOO056}+=10))"
ARRAY=(1 2 3 4 5)
FOO059="$((100**0))"
FOO060="$((FOO059||FOO059++))"
FOO061="$((0&&FOO059++))"
