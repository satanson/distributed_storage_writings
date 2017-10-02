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

charset_info_st is object that represents a  charset

```c++
//strings/ctype-latin1.c

struct charset_info_st my_charset_latin1=
{
    8,0,0,              /* number    */
    MY_CS_COMPILED | MY_CS_PRIMARY, /* state     */
    "latin1",               /* cs name    */
    "latin1_swedish_ci",        /* name      */
    "",                 /* comment   */
    NULL,               /* tailoring */
    ctype_latin1,
    to_lower_latin1,
    to_upper_latin1,
    sort_order_latin1,
    NULL,       /* uca          */
    cs_to_uni,      /* tab_to_uni   */
    NULL,       /* tab_from_uni */
    &my_unicase_default,/* caseinfo     */
    NULL,       /* state_map    */
    NULL,       /* ident_map    */
    1,          /* strxfrm_multiply */
    1,                  /* caseup_multiply  */
    1,                  /* casedn_multiply  */
    1,          /* mbminlen   */
    1,          /* mbmaxlen  */
    0,          /* min_sort_char */
    255,        /* max_sort_char */
    ' ',                /* pad char      */
    0,                  /* escape_with_backslash_is_dangerous */
    1,                  /* levels_for_order   */
    &my_charset_handler,
    &my_collation_8bit_simple_ci_handler
};

```



```c++
//include/m_ctype.h
#define my_strnncoll(s, a, b, c, d) ((s)->coll->strnncoll((s), (a), (b), (c), (d), 0))
```



**my_strnncoll_gbk_chinese_ci**

strings/strcoll.ic

```c++
static int
MY_FUNCTION_NAME(strnncoll)(CHARSET_INFO *cs __attribute__((unused)),
                            const uchar *a, size_t a_length, 
                            const uchar *b, size_t b_length,
                            my_bool b_is_prefix)

static inline uint
MY_FUNCTION_NAME(scan_weight)(int *weight, const uchar *str, const uchar *end)
```



