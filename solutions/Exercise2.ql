import cpp

class UnsignedInt extends IntType {
  UnsignedInt() { this.isUnsigned() }
}

from Variable v
where v.getUnspecifiedType() instanceof UnsignedInt
select v
