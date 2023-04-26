/**
 * @ kind problem
 */

import cpp

from IntegralConversion conv, IntType src, IntType dst
where
  // original type
  src = conv.getExpr().getUnspecifiedType().(IntType) and
  src.isUnsigned() and
  // converted type
  dst = conv.getUnspecifiedType().(IntType) and
  dst.isSigned()
select conv, "original type: " + src + " Converted type: " + conv.getUnspecifiedType().(IntType)
