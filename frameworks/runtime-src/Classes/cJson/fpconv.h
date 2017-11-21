
#if defined(_WIN32) && defined(_WINDOWS)

#ifndef snprintf
#define snprintf _snprintf
#endif

#ifndef strncasecmp
#define strncasecmp strnicmp
#endif

#ifndef strcasecmp
#define strcasecmp stricmp
#endif

#ifndef isnan
#define isnan   _isnan
#endif

#ifndef isinf
#define isinf(x)   (!_finite(x))
#endif

#endif




/* Lua CJSON floating point conversion routines */

/* Buffer required to store the largest string representation of a double.
 *
 * Longest double printed with %.14g is 21 characters long:
 * -1.7976931348623e+308 */
# define FPCONV_G_FMT_BUFSIZE   32

#ifdef USE_INTERNAL_FPCONV
static inline void fpconv_init()
{
    /* Do nothing - not required */
}
#else
extern inline void fpconv_init();
#endif

extern int fpconv_g_fmt(char*, double, int);
extern double fpconv_strtod(const char*, char**);

/* vi:ai et sw=4 ts=4:
 */
