# Decimal
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
# origine : https://github.com/status-im/nim-decimal
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import dcml_lowlevel

when not declared(strformat) :
  import strformat

when not declared(typetraits) :
  import typetraits



from strutils import Digits, parseInt,replace , repeat , isDigit ,formatFloat,delete , align



when not declared(Dcml) :

  type
    Dcml* = ref[ptr mpd_t]
    DcmlError* = object of Exception
  
  #const
    #DEFAULT_PREC = MPD_RDIGITS * 2
    #DEFAULT_EMAX = when (sizeof(int) == 8): 999999999999999999 else: 425000000
    #DEFAULT_EMIN = when (sizeof(int) == 8): -999999999999999999 else: -425000000
  
  
  
  var CTX: mpd_context_t
  var CTX_ADDR = addr CTX
  mpd_defaultcontext(CTX_ADDR)
  
  #@@@@@@@@@@@@@@@@@@
  #------------------
  let cMaxDigit : uint8 = 34
  
  proc Valide*(a: Dcml)
  proc Rtrim*(a: Dcml)
  proc Round*(a: Dcml; iScale:int )
  proc Rjust*(a: Dcml)
  #------------------
  
 
  #----------------------------------------------------
  ## BORNAGE POUR LA GESTION compta : stock etc....
  #----------------------------------------------------  
  
  proc newDcml*( iEntier: uint8 ; iScale : uint8; nullable : bool =true ): Dcml =
    ## Initialize a empty Dcml
  
    if iEntier + iScale  > cMaxDigit or ( iEntier == 0 and iScale == 0 ):
      raise newException(DcmlError, fmt"Failed Init {iEntier},{iScale}")
  
    var i:int = parseInt(fmt"{cMaxDigit}")
    let success = mpd_qsetprec(CTX_ADDR, i)
    if success == 0:
      raise newException(DcmlError, fmt"Couldn't set precision {cMaxDigit} ")
  
    var r = new Dcml
    r[] = mpd_qnew()
    r.entier = iEntier
    r.scale  = iScale
    mpd_set_string(r[], "0", CTX_ADDR)
    r.nullable = nullable
    return r



  proc `$`*(a: Dcml): string =
      ## Convert Dcml to string for echo
      a.Valide()
      $mpd_to_sci(a[], 0)
  
  # edit val sans contrôle 
  proc debug*(a: Dcml):string =
    ## Convert Dcml to string natural of basic mpd
    $mpd_to_sci(a[], 0)
  
  proc signed*(a: Dcml): string =
    ## Convert Dcml to string force signed '+'
    var s: string = $mpd_to_sci(a[], 0)
    if s[0].isDigit == true : return fmt"+{s}"
    else: return fmt"{s}"
  
  proc align*(a: Dcml,len : int): string = 
    var s: string = $mpd_to_sci(a[], 0)
    return align(s,len)

  proc alignsigned*(a: Dcml,len : int): string = 
    var s: string = $mpd_to_sci(a[], 0)
    if s[0].isDigit == true : s = fmt"+{s}"
    return align(s,len)

  proc clone*(a: Dcml): Dcml =
    ## Clone a Dcml and returns a new independent one
    var status: uint32
    var r = new Dcml
    r[] = mpd_qnew()
    let success = mpd_qcopy(r[], a[], addr status)
    if success == 0:
      raise newException(DcmlError, "Decimal failed to copy")
    r.entier = a.entier
    r.scale  = a.scale
    r.nullable  = a.nullable
    return r
  
  
  proc isBool*(a: Dcml): bool =
    if a.nullable == true : return true
    else : return false
  
  proc isStringDigit*(str: string): bool =
    ## Reimplementation of isDigit for strings
    if str.len() == 0: return false
    for i in str:
      if not isDigit(i): return false
    return true


  # Operators  := + - * / ^ //
  
  
  ## assignement valeur 
  proc `:=`*(a, b : Dcml) =
    var status: uint32
    mpd_copy_data(a[],b[],addr status)
  
  template `:=`*[T: SomeNumber ](a: Dcml, x: T) =
    ## ADD decimal from X
    var n = x  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32" , "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération :=")
    a := b
  
  proc `:=`*(a : Dcml, x:string)  =
    var sVal:string = x
    #test par defaut
    if (sVal == "" or sVal=="0" ) :  
      sVal="0"
      sVal = sVal.replace("+","" )
      sVal = sVal.replace("-","" )
      sVal = sVal.replace(".","" )
      if sVal.isStringDigit() == false :  
        raise newException(DcmlError, "Decimal failed to newDecimal(String)")
    mpd_set_string(a[], sVal, CTX_ADDR)
    a.Rjust()


  proc `+=`*(a, b: Dcml)=
    var status: uint32
    mpd_qadd(a[], a[], b[], CTX_ADDR, addr status)
  
  
  template `+=`*[T: SomeNumber](a: Dcml, x: T) =
    ## ADD decimal from X
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération +")
    a += b
  
  
  
  
  
  proc `-=`*(a, b: Dcml) =
    ## SUB decimal from X
    var status: uint32
    mpd_qsub(a[], a[], b[], CTX_ADDR, addr status)
  
  
  
  template `-=`*[T: SomeNumber](a: Dcml, x: T)=
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération -")
    a -= b
  
  
  
  
  
  proc `*=`*(a, b: Dcml)=
    ## MULT decimal from X
    var status: uint32
    mpd_qmul(a[], a[], b[], CTX_ADDR, addr status)
  
  template `*=`*[T: SomeNumber](a: Dcml, x: T) =
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération *")
    a *= b
  
  
  
  
  
  proc `/=`*(a, b: Dcml) =
    ## DIV decimal from X
    var status: uint32
    var x = new Dcml
    x[] = mpd_qnew()

    x := "0"
    let cmp = mpd_qcmp(b[], x[], addr status)
    if (cmp == 0) :
      raise newException(DcmlError, fmt"Failed Operation : DIV {a} / {b} ")
    else :
      mpd_qdiv(a[], a[], b[], CTX_ADDR, addr status)
  
  template `/=`*[T: SomeNumber](a: Dcml, x: T)=
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()

    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération /")
    a /= b
  
  
  
  
  
  proc `//=`*(a, b: Dcml)=
    ## DIVINTEGER  decimal from X
    var status: uint32
    mpd_qdivint(a[], a[], b[], CTX_ADDR, addr status)
  
  
  template `//=`*[T: SomeNumber](a: Dcml, x: T)=
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération //")
    a //= b
  
  
  
  
  
  proc `^=`*(a, b: Dcml) =
    ## POWER   decimal from X
    var status: uint32
    mpd_qpow(a[], a[], b[], CTX_ADDR, addr status)
  
  
  template `^=`*[T: SomeNumber](a: Dcml, x: T)=
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération ^")
    a ^= b
  
  
  
  
  
  
  
  
  
  ## comparaison
  
  proc `==`*(a, b: Dcml): bool =
    var status: uint32
    let cmp = mpd_qcmp(a[], b[], addr status)
    if cmp == 0:
      return true
    else:
      return false
  
  template `==`*[T: SomeNumber](a: Dcml, x: T):bool=
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
        b.Rtrim()
      else :
        raise newException(DcmlError, "Failed opération ==")
    a == b
  
  template `==`*[T: SomeNumber](x: T, b: Dcml):bool =
    var n = x
  
    var a = new Dcml
    a[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(a[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(a[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(a[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(a[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(a[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération ==")
    a == b
  
  
  
  proc `<`*(a, b: Dcml): bool =
    var status: uint32
    let cmp = mpd_qcmp(a[], b[], addr status)
    if cmp == -1:
      return true
    else:
      return false
  
  template `<`*[T: SomeNumber](a: Dcml, x: T):bool =
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération <")
    a < b
  
  template `<`*[T: SomeNumber](x: T, b: Dcml):bool =
    var n = x
  
    var a = new Dcml
    a[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(a[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(a[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(a[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(a[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(a[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération <")
    a < b
    
  proc `<=`*(a, b: Dcml): bool =
    let less_cmp = a < b
    if less_cmp: return true
    let equal_cmp = a == b
    if equal_cmp: return true
    return false

  template `<=`*[T: SomeNumber](a: Dcml, x: T): bool =
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération <=")
    a <= b
  
  template `<=`*[T: SomeNumber](x: T, b: Dcml): bool =
    var n = x
  
    var a = new Dcml
    a[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(a[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(a[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(a[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(a[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(a[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération <=")
    a <= b
  
  
  
  
  proc `>`*(a, b: Dcml): bool =
    var status: uint32
    let cmp = mpd_qcmp(a[], b[], addr status)
    if cmp == 1:
      return true
    else:
      return false
  
  template `>`*[T: SomeNumber](a: Dcml, x: T): bool =
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération >")
    a > b
  
  
  template `>`*[T: SomeNumber](x: T, b: Dcml) : bool=
    var n = x
  
    var a = new Dcml
    a[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(a[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(a[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(a[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(a[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(a[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération >")
    a > b

  proc `>=`*(a, b: Dcml): bool =
    let less_cmp = a > b
    if less_cmp: return true
    let equal_cmp = a == b
    if equal_cmp: return true
    return false
  
  
  template `>=`*[T: SomeNumber](a: Dcml, x: T): bool =
    var n = x
  
    var b = new Dcml
    b[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(b[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(b[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(b[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(b[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(b[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(b[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(b[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération >=")
    a >= b
  
  
  template `>=`*[T: SomeNumber](x: T, b: Dcml) : bool =
    var n = x
    
    var a = new Dcml
    a[] = mpd_qnew()
    
    case name(type(n)) :
      of "int8" , "int16" ,"int32" :
        mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "int64" :
        mpd_set_i64(a[], int64(x), CTX_ADDR)
  
      of "int" :
        when (sizeof(int(x)) == 8):
          mpd_set_i64(a[], int64(x), CTX_ADDR)
        else:
          mpd_set_i32(a[], int32(x), CTX_ADDR)
  
      of "uint8" , "uint16" ,"uint32" :
        mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "uint64" :
        mpd_set_u64(a[], uint64(x), CTX_ADDR)
  
      of "uint" :
        when (sizeof(uint(x)) == 8):
          mpd_set_u64(a[], uint64(x), CTX_ADDR)
        else:
          mpd_set_u32(a[], uint32(x), CTX_ADDR)
  
      of "float", "float32", "float64" :
        var s: string = formatFloat(float(n)) 
        mpd_set_string(a[], s, CTX_ADDR)
      else :
        raise newException(DcmlError, "Failed opération >=")
    a >= b
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  ##----------------------------------------------------------------------------
  ## fonction avec decimal libre  
  ## Math functions
  ##----------------------------------------------------------------------------
  
  proc divint*(r,a, b: Dcml) =
    ## Integer division, same ass //
    var status: uint32
    mpd_qdivint(r[], a[], b[], CTX_ADDR, addr status)
  
  
  
  proc rem*(r ,a, b: Dcml) =
    ## Returns the remainder of the division a/b
    var status: uint32
    mpd_qrem(r[], a[], b[], CTX_ADDR, addr status)
  
  
  
  # Math functions
  
  proc minus*(a: Dcml) =
    ## Negation operator
    var status: uint32
    mpd_qminus(a[], a[], CTX_ADDR, addr status)
  
  
  
  proc plus*(a: Dcml) =
    var status: uint32
    mpd_qplus(a[], a[], CTX_ADDR, addr status)
    var sPlus:string = $mpd_to_sci(a[], 0)
    mpd_set_string(a[], sPlus, CTX_ADDR)
  
  
  
  
  proc floor*(r,a: Dcml) =
    ## Return the nearest integer towards -infinity
    var status: uint32
    mpd_qfloor(r[], a[], CTX_ADDR, addr status)
  
  
  
  proc ceil*(r,a: Dcml) =
    ## Return the nearest integer towards +infinity
    var status: uint32
    mpd_qceil(r[], a[], CTX_ADDR, addr status)
  
  
  proc truncate*(a: Dcml) =
    ## Return the truncated value of a
    var status: uint32
    mpd_qtrunc(a[], a[], CTX_ADDR, addr status)
  
  
  
  proc finalize*(a: Dcml) =
    ## Apply the current context to a
    var status: uint32
    mpd_qfinalize(a[], CTX_ADDR, addr status)
  
  
  proc Rtrim*(a: Dcml) =
    if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
      raise newException(DcmlError, fmt"Failed Init : Rtrim value:{$mpd_to_sci(a[], 0)}")
    ## trailing zeros removed
    var r = new Dcml
    r[] = mpd_qnew()
  
    var iScale:int = int(a.scale)
    var sNumber:string = $mpd_to_sci(a[], 0)
    var iPos: int = sNumber.find('.')
    var iLen: int
  
    if iPos >= 0 : iPos += int(1)
  
    if iPos == -1: return
    # delete zeros 
  
    while true :
      iLen = sNumber.len()
      iLen -= iPos
      if sNumber[sNumber.len()-1] == '0' and iLen > iScale  :
        sNumber.delete(sNumber.len()-1,sNumber.len())
      else:
        break
      
    mpd_set_string(a[], sNumber, CTX_ADDR)
  
  
  
  
  
  proc eval*(n:Dcml ,xs: varargs[string, `$`]) =
    var r = clone(n)
    var s = new Dcml
    s[] = mpd_qnew()
    var signe : string
  
    for x in xs:
      if x == "=" or x == "+" or x == "-" or x == "*" or x == "/" or x == "%" or x == "+%" or x == "-%" or x == "*%" or x == "/%":
        signe = x
      else :
        r := x
        case signe:
          of "=" :
            n:=r
            signe=""
            
          of "+" :
            n+=r
          of "-" :
            n-=r
            signe=""
  
          of "*" :
            n*=r
            signe=""
  
          of "/" :
            n/=r
            signe=""
  
          of "%" :
            n/=100
            n*=r
            signe=""
  
          of "+%" :
            s:=n
            s/=100
            s*=r
            n+=s
            signe=""
  
          of "-%" :
            s:=n
            s/=100
            s*=r
            n-=s
            signe=""
  
          of "*%" :
            s:=n
            s/=100
            s*=r
            n*=s
            signe=""
  
          of "/%" :
            s:=n
            s/=100
            s*=r
            n/=s
            signe=""
  
          else:
            raise newException(DcmlError, fmt"Failed : eval value:{$mpd_to_sci(n[], 0)}")

  
  #---------------------------------------
  # contrôle len buffer and caractéristique  
  # maximun 38 digits
  #---------------------------------------
  
  proc isErr*(a: Dcml):bool =
    if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
      raise newException(DcmlError, fmt"Failed Init : isErr value:{$mpd_to_sci(a[], 0)}")
    ## contrôle dépassement capacité
    var r = new Dcml
    r[] = mpd_qnew()
    r = clone(a)
    r.Rtrim()
    var iEntier:int = int(a.entier)
    var iScale:int = int(a.scale)
    var sNumber:string = $mpd_to_sci(r[], 0)
    var iMax:int =  iEntier + iScale
    var iLen:int =  sNumber.len()
  
  
    if iEntier == 0 : 
      iMax = iMax + 1
      iLen = iLen - 1
    if sNumber.find('-') > -1 : 
      iMax = iMax - 1
      iLen = iLen - 1 
    if sNumber.find('+') > -1 :
      iMax = iMax - 1
      iLen = iLen - 1
    if sNumber.find('.') > -1 :
      iMax = iMax - 1
      iLen = iLen - 1
  
    if iMax > int(cMaxDigit)  or iMax < iLen:
      return true
    else : 
      return false
  
  
  #---------------------------------------
  # formatage 
  # alustement rigth zeros
  #---------------------------------------
  proc Rjust*(a: Dcml)=
  #  if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
  #    raise newException(DcmlError, fmt"Failed Init : Rjust value:{$mpd_to_sci(a[], 0)}")
    let padding = '0'
  
    var iScale:int = int(a.scale)
    var sNumber:string = $mpd_to_sci(a[], 0)
    var iLen: int
    var iRst: int
    var iPos: int = sNumber.find('.')

    if iScale == 0 : return

    if iPos == -1 :
      sNumber.add(".")


    iPos = sNumber.find('.')
    iLen  = sNumber.len() - 1
    # nombre de digit manquant
    iRst = iLen - iPos
    if iRst < iScale :
      sNumber.add(padding.repeat(iScale - iRst))
      mpd_set_string(a[], sNumber, CTX_ADDR)
  
  
  
  #---------------------------------------
  # ARRONDI comptable / commercial   
  # 5 => + 1 
  # maximun 38 digits 
  #---------------------------------------
  
  proc Round*(a: Dcml; iScale:int )=
    var status: uint32
    var CTXN: mpd_context_t
    var CTX_CTRL = addr CTXN
    CTX_CTRL.round = MPD_ROUND_05UP
  

    var r = new Dcml
    r[] = mpd_qnew()
    r:=a
  
    if iScale > 0 :
      
      for i in 1..iScale :
        r *= 10
      mpd_qround_to_intx(r[], r[], CTX_CTRL, addr status)
      for i in 1..iScale :
        r /= 10
  
    else:
      r.floor(r)
  
    mpd_copy_data(a[],r[],addr status)

  #---------------------------------------
  # contrôle &  validité PAS D'ARRONDI 
  # formatage 
  # maximun 38 digits
  #---------------------------------------
  
  proc Valide*(a: Dcml) =
    ## controle dépassement capacité
    if (a.entier + a.scale) > cMaxDigit or (a.entier == uint8(0) and a.scale == uint8(0)) :
      raise newException(DcmlError, fmt"Failed Init : Valide value:{$mpd_to_sci(a[], 0)}")
    var status: uint32
    var CTXN: mpd_context_t
    var CTX_CTRL = addr CTXN
    CTX_CTRL.round = MPD_ROUND_05UP
  
  
    var iEntier:int = int(a.entier)
  
    var iScale:int = int(a.scale)
  
    var sEntier:string
  
    var i :int 
    var r = new Dcml
    r[] = mpd_qnew()
    # control partie entiere
  
    r.floor(a)
  
    sEntier= $mpd_to_sci(r[], 0)
    sEntier = sEntier.replace("+","" )
    sEntier = sEntier.replace("-","" )
    i = sEntier.len
  
    # dcml(0.x) on ne compte pas si 0 entier
    if i == 1 and  sEntier[0] == '0':
      i = 0
  
    if i > iEntier :
      raise newException(DcmlError, fmt"Overlay Digit : Valide value:{$mpd_to_sci(a[], 0)} ") 
  
    ## formatages 
    ## suppression des digits scale en trop  

    if iScale != 0 :
      if r == a :
        sEntier= fmt"{sEntier}."
        for i in 1..iScale :
          sEntier = fmt"{sEntier}0"
        mpd_set_string(r[], sEntier, CTX_ADDR)
      else :
        mpd_copy_data(r[],a[],addr status)
        for i in 1..iScale :
          r*=10
        r.truncate()
        for i in 1..iScale :
          r/=10
    
    mpd_copy_data(a[],r[],addr status)
    a.Rjust()
