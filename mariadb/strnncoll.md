# strnncol

strings/ctype-simple.c

CHARSET_INFO::sort_order define a total order of letters



```c++
int my_strnncoll_simple(CHARSET_INFO * cs, const uchar *s, size_t slen, 
                        const uchar *t, size_t tlen,
                        my_bool t_is_prefix)
{
  size_t len = ( slen > tlen ) ? tlen : slen;
  const uchar *map= cs->sort_order;
  if (t_is_prefix && slen > tlen)
    slen=tlen;
  while (len--)
  {
    if (map[*s++] != map[*t++])
      return ((int) map[s[-1]] - (int) map[t[-1]]);
  }
  /*
    We can't use (slen - tlen) here as the result may be outside of the
    precision of a signed int
  */
  return slen > tlen ? 1 : slen < tlen ? -1 : 0 ;
}

```

