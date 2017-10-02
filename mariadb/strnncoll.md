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



MY_COLLATION_HANDER is a function table for handling something abort collation



```c++
MY_COLLATION_HANDLER my_collation_8bit_simple_ci_handler =
{
    my_coll_init_simple,    /* init */
    my_strnncoll_simple,
    my_strnncollsp_simple,
    my_strnxfrm_simple,
    my_strnxfrmlen_simple,
    my_like_range_simple,
    my_wildcmp_8bit,
    my_strcasecmp_8bit,
    my_instr_simple,
    my_hash_sort_simple,
    my_propagate_simple
};

```

/