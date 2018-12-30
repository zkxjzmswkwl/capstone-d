/// Types and constants of PowerPc architecture
module capstone.ppc;

import std.variant;
import std.exception: enforce;

import capstone.internal;
import capstone.utils;

/** Instruction's operand referring to memory

This is associated with the `PpcOpType.mem` operand type
*/
struct PpcOpMem {
	PpcRegister base; // base register
	int disp;		  // displacement/offset value
}

/** Instruction's operand referring to a conditional register

This is associated with the `PpcOpType.crx` operand type
*/
struct PpcOpCrx {
	uint scale;
	PpcRegister reg;
	PpcBc cond;
}

/// Tagged union of possible operand types
alias PpcOpValue = TaggedUnion!(PpcRegister, "reg", long, "imm", PpcOpMem, "mem", PpcOpCrx, "crx");

/// Instruction's operand
struct PpcOp {
    PpcOpType type;   /// Operand type
    PpcOpValue value; /// Operand value of type `type`
    alias value this; /// Convenient access to value (as in original bindings)

    package this(cs_ppc_op internal){
        type = internal.type;
        final switch(internal.type) {
            case PpcOpType.invalid:
                break;
            case PpcOpType.reg:
                value.reg = internal.reg;
                break;
            case PpcOpType.imm:
                value.imm = internal.imm;
                break;
            case PpcOpType.mem:
                value.mem = internal.mem;
                break;
            case PpcOpType.crx:
                value.crx = internal.crx;
                break;
        }
    }
}

/// Ppc-specific information about an instruction
struct PpcInstructionDetail {
	PpcBc bc;		  /// Branch code for branch instructions
	PpcBh bh;		  /// Branch hint for branch instructions
	bool updateCr0;	  /// If true, then this 'dot' instruction updates CR0
    PpcOp[] operands; /// Operands for this instruction.

    package this(cs_arch_detail arch_detail){
		this(arch_detail.ppc);
	}
    package this(cs_ppc internal){
		bc = internal.bc;
		bh = internal.bh;
		updateCr0 = internal.update_cr0;
        foreach(op; internal.operands[0..internal.op_count])
            operands ~= PpcOp(op);
    }
}

//=============================================================================
// Constants
//=============================================================================

/// Operand type for instruction's operands
enum PpcOpType {
	invalid = 0, // Uninitialized
	reg, 		 // Register operand
	imm, 		 // Immediate operand
	mem, 		 // Memory operand
	crx = 64,	 // Condition Register field
}

/// PPC branch codes for some branch instructions
enum PpcBc {
	invalid  = 0,
	lt       = (0 << 5) | 12,
	le       = (1 << 5) |  4,
	eq       = (2 << 5) | 12,
	ge       = (0 << 5) |  4,
	gt       = (1 << 5) | 12,
	ne       = (2 << 5) |  4,
	un       = (3 << 5) | 12,
	nu       = (3 << 5) |  4,

	// Extra conditions
	so = (4 << 5) | 12,	/// Summary overflow
	ns = (4 << 5) | 4,	/// Not summary overflow
}

/// PPC branch hint for some branch instructions
enum PpcBh {
	invalid = 0, /// No hint
	plus,		 /// PLUS hint
	minus,		 /// MINUS hint
}

/// PPC registers
enum PpcRegister {
	invalid = 0,

	carry,
	cr0,
	cr1,
	cr2,
	cr3,
	cr4,
	cr5,
	cr6,
	cr7,
	ctr,
	f0,
	f1,
	f2,
	f3,
	f4,
	f5,
	f6,
	f7,
	f8,
	f9,
	f10,
	f11,
	f12,
	f13,
	f14,
	f15,
	f16,
	f17,
	f18,
	f19,
	f20,
	f21,
	f22,
	f23,
	f24,
	f25,
	f26,
	f27,
	f28,
	f29,
	f30,
	f31,
	lr,
	r0,
	r1,
	r2,
	r3,
	r4,
	r5,
	r6,
	r7,
	r8,
	r9,
	r10,
	r11,
	r12,
	r13,
	r14,
	r15,
	r16,
	r17,
	r18,
	r19,
	r20,
	r21,
	r22,
	r23,
	r24,
	r25,
	r26,
	r27,
	r28,
	r29,
	r30,
	r31,
	v0,
	v1,
	v2,
	v3,
	v4,
	v5,
	v6,
	v7,
	v8,
	v9,
	v10,
	v11,
	v12,
	v13,
	v14,
	v15,
	v16,
	v17,
	v18,
	v19,
	v20,
	v21,
	v22,
	v23,
	v24,
	v25,
	v26,
	v27,
	v28,
	v29,
	v30,
	v31,
	vrsave,
	vs0,
	vs1,
	vs2,
	vs3,
	vs4,
	vs5,
	vs6,
	vs7,
	vs8,
	vs9,
	vs10,
	vs11,
	vs12,
	vs13,
	vs14,
	vs15,
	vs16,
	vs17,
	vs18,
	vs19,
	vs20,
	vs21,
	vs22,
	vs23,
	vs24,
	vs25,
	vs26,
	vs27,
	vs28,
	vs29,
	vs30,
	vs31,
	vs32,
	vs33,
	vs34,
	vs35,
	vs36,
	vs37,
	vs38,
	vs39,
	vs40,
	vs41,
	vs42,
	vs43,
	vs44,
	vs45,
	vs46,
	vs47,
	vs48,
	vs49,
	vs50,
	vs51,
	vs52,
	vs53,
	vs54,
	vs55,
	vs56,
	vs57,
	vs58,
	vs59,
	vs60,
	vs61,
	vs62,
	vs63,
	q0,
	q1,
	q2,
	q3,
	q4,
	q5,
	q6,
	q7,
	q8,
	q9,
	q10,
	q11,
	q12,
	q13,
	q14,
	q15,
	q16,
	q17,
	q18,
	q19,
	q20,
	q21,
	q22,
	q23,
	q24,
	q25,
	q26,
	q27,
	q28,
	q29,
	q30,
	q31,

	// Extra registers for PPCMapping.c
	rm,
	ctr8,
	lr8,
	cr1EQ,
	x2,
}

/// PPC instruction
enum PpcInstructionId {
	invalid = 0,

	add,
	addc,
	adde,
	addi,
	addic,
	addis,
	addme,
	addze,
	and,
	andc,
	andis,
	andi,
	attn,
	b,
	ba,
	bc,
	bcctr,
	bcctrl,
	bcl,
	bclr,
	bclrl,
	bctr,
	bctrl,
	bct,
	bdnz,
	bdnza,
	bdnzl,
	bdnzla,
	bdnzlr,
	bdnzlrl,
	bdz,
	bdza,
	bdzl,
	bdzla,
	bdzlr,
	bdzlrl,
	bl,
	bla,
	blr,
	blrl,
	brinc,
	cmpb,
	cmpd,
	cmpdi,
	cmpld,
	cmpldi,
	cmplw,
	cmplwi,
	cmpw,
	cmpwi,
	cntlzd,
	cntlzw,
	creqv,
	crxor,
	crand,
	crandc,
	crnand,
	crnor,
	cror,
	crorc,
	dcba,
	dcbf,
	dcbi,
	dcbst,
	dcbt,
	dcbtst,
	dcbz,
	dcbzl,
	dccci,
	divd,
	divdu,
	divw,
	divwu,
	dss,
	dssall,
	dst,
	dstst,
	dststt,
	dstt,
	eqv,
	evabs,
	evaddiw,
	evaddsmiaaw,
	evaddssiaaw,
	evaddumiaaw,
	evaddusiaaw,
	evaddw,
	evand,
	evandc,
	evcmpeq,
	evcmpgts,
	evcmpgtu,
	evcmplts,
	evcmpltu,
	evcntlsw,
	evcntlzw,
	evdivws,
	evdivwu,
	eveqv,
	evextsb,
	evextsh,
	evldd,
	evlddx,
	evldh,
	evldhx,
	evldw,
	evldwx,
	evlhhesplat,
	evlhhesplatx,
	evlhhossplat,
	evlhhossplatx,
	evlhhousplat,
	evlhhousplatx,
	evlwhe,
	evlwhex,
	evlwhos,
	evlwhosx,
	evlwhou,
	evlwhoux,
	evlwhsplat,
	evlwhsplatx,
	evlwwsplat,
	evlwwsplatx,
	evmergehi,
	evmergehilo,
	evmergelo,
	evmergelohi,
	evmhegsmfaa,
	evmhegsmfan,
	evmhegsmiaa,
	evmhegsmian,
	evmhegumiaa,
	evmhegumian,
	evmhesmf,
	evmhesmfa,
	evmhesmfaaw,
	evmhesmfanw,
	evmhesmi,
	evmhesmia,
	evmhesmiaaw,
	evmhesmianw,
	evmhessf,
	evmhessfa,
	evmhessfaaw,
	evmhessfanw,
	evmhessiaaw,
	evmhessianw,
	evmheumi,
	evmheumia,
	evmheumiaaw,
	evmheumianw,
	evmheusiaaw,
	evmheusianw,
	evmhogsmfaa,
	evmhogsmfan,
	evmhogsmiaa,
	evmhogsmian,
	evmhogumiaa,
	evmhogumian,
	evmhosmf,
	evmhosmfa,
	evmhosmfaaw,
	evmhosmfanw,
	evmhosmi,
	evmhosmia,
	evmhosmiaaw,
	evmhosmianw,
	evmhossf,
	evmhossfa,
	evmhossfaaw,
	evmhossfanw,
	evmhossiaaw,
	evmhossianw,
	evmhoumi,
	evmhoumia,
	evmhoumiaaw,
	evmhoumianw,
	evmhousiaaw,
	evmhousianw,
	evmra,
	evmwhsmf,
	evmwhsmfa,
	evmwhsmi,
	evmwhsmia,
	evmwhssf,
	evmwhssfa,
	evmwhumi,
	evmwhumia,
	evmwlsmiaaw,
	evmwlsmianw,
	evmwlssiaaw,
	evmwlssianw,
	evmwlumi,
	evmwlumia,
	evmwlumiaaw,
	evmwlumianw,
	evmwlusiaaw,
	evmwlusianw,
	evmwsmf,
	evmwsmfa,
	evmwsmfaa,
	evmwsmfan,
	evmwsmi,
	evmwsmia,
	evmwsmiaa,
	evmwsmian,
	evmwssf,
	evmwssfa,
	evmwssfaa,
	evmwssfan,
	evmwumi,
	evmwumia,
	evmwumiaa,
	evmwumian,
	evnand,
	evneg,
	evnor,
	evor,
	evorc,
	evrlw,
	evrlwi,
	evrndw,
	evslw,
	evslwi,
	evsplatfi,
	evsplati,
	evsrwis,
	evsrwiu,
	evsrws,
	evsrwu,
	evstdd,
	evstddx,
	evstdh,
	evstdhx,
	evstdw,
	evstdwx,
	evstwhe,
	evstwhex,
	evstwho,
	evstwhox,
	evstwwe,
	evstwwex,
	evstwwo,
	evstwwox,
	evsubfsmiaaw,
	evsubfssiaaw,
	evsubfumiaaw,
	evsubfusiaaw,
	evsubfw,
	evsubifw,
	evxor,
	extsb,
	extsh,
	extsw,
	eieio,
	fabs,
	fadd,
	fadds,
	fcfid,
	fcfids,
	fcfidu,
	fcfidus,
	fcmpu,
	fcpsgn,
	fctid,
	fctiduz,
	fctidz,
	fctiw,
	fctiwuz,
	fctiwz,
	fdiv,
	fdivs,
	fmadd,
	fmadds,
	fmr,
	fmsub,
	fmsubs,
	fmul,
	fmuls,
	fnabs,
	fneg,
	fnmadd,
	fnmadds,
	fnmsub,
	fnmsubs,
	fre,
	fres,
	frim,
	frin,
	frip,
	friz,
	frsp,
	frsqrte,
	frsqrtes,
	fsel,
	fsqrt,
	fsqrts,
	fsub,
	fsubs,
	icbi,
	icbt,
	iccci,
	isel,
	isync,
	la,
	lbz,
	lbzcix,
	lbzu,
	lbzux,
	lbzx,
	ld,
	ldarx,
	ldbrx,
	ldcix,
	ldu,
	ldux,
	ldx,
	lfd,
	lfdu,
	lfdux,
	lfdx,
	lfiwax,
	lfiwzx,
	lfs,
	lfsu,
	lfsux,
	lfsx,
	lha,
	lhau,
	lhaux,
	lhax,
	lhbrx,
	lhz,
	lhzcix,
	lhzu,
	lhzux,
	lhzx,
	li,
	lis,
	lmw,
	lswi,
	lvebx,
	lvehx,
	lvewx,
	lvsl,
	lvsr,
	lvx,
	lvxl,
	lwa,
	lwarx,
	lwaux,
	lwax,
	lwbrx,
	lwz,
	lwzcix,
	lwzu,
	lwzux,
	lwzx,
	lxsdx,
	lxvd2x,
	lxvdsx,
	lxvw4x,
	mbar,
	mcrf,
	mcrfs,
	mfcr,
	mfctr,
	mfdcr,
	mffs,
	mflr,
	mfmsr,
	mfocrf,
	mfspr,
	mfsr,
	mfsrin,
	mftb,
	mfvscr,
	msync,
	mtcrf,
	mtctr,
	mtdcr,
	mtfsb0,
	mtfsb1,
	mtfsf,
	mtfsfi,
	mtlr,
	mtmsr,
	mtmsrd,
	mtocrf,
	mtspr,
	mtsr,
	mtsrin,
	mtvscr,
	mulhd,
	mulhdu,
	mulhw,
	mulhwu,
	mulld,
	mulli,
	mullw,
	nand,
	neg,
	nop,
	ori,
	nor,
	or,
	orc,
	oris,
	popcntd,
	popcntw,
	qvaligni,
	qvesplati,
	qvfabs,
	qvfadd,
	qvfadds,
	qvfcfid,
	qvfcfids,
	qvfcfidu,
	qvfcfidus,
	qvfcmpeq,
	qvfcmpgt,
	qvfcmplt,
	qvfcpsgn,
	qvfctid,
	qvfctidu,
	qvfctiduz,
	qvfctidz,
	qvfctiw,
	qvfctiwu,
	qvfctiwuz,
	qvfctiwz,
	qvflogical,
	qvfmadd,
	qvfmadds,
	qvfmr,
	qvfmsub,
	qvfmsubs,
	qvfmul,
	qvfmuls,
	qvfnabs,
	qvfneg,
	qvfnmadd,
	qvfnmadds,
	qvfnmsub,
	qvfnmsubs,
	qvfperm,
	qvfre,
	qvfres,
	qvfrim,
	qvfrin,
	qvfrip,
	qvfriz,
	qvfrsp,
	qvfrsqrte,
	qvfrsqrtes,
	qvfsel,
	qvfsub,
	qvfsubs,
	qvftstnan,
	qvfxmadd,
	qvfxmadds,
	qvfxmul,
	qvfxmuls,
	qvfxxcpnmadd,
	qvfxxcpnmadds,
	qvfxxmadd,
	qvfxxmadds,
	qvfxxnpmadd,
	qvfxxnpmadds,
	qvgpci,
	qvlfcdux,
	qvlfcduxa,
	qvlfcdx,
	qvlfcdxa,
	qvlfcsux,
	qvlfcsuxa,
	qvlfcsx,
	qvlfcsxa,
	qvlfdux,
	qvlfduxa,
	qvlfdx,
	qvlfdxa,
	qvlfiwax,
	qvlfiwaxa,
	qvlfiwzx,
	qvlfiwzxa,
	qvlfsux,
	qvlfsuxa,
	qvlfsx,
	qvlfsxa,
	qvlpcldx,
	qvlpclsx,
	qvlpcrdx,
	qvlpcrsx,
	qvstfcdux,
	qvstfcduxa,
	qvstfcduxi,
	qvstfcduxia,
	qvstfcdx,
	qvstfcdxa,
	qvstfcdxi,
	qvstfcdxia,
	qvstfcsux,
	qvstfcsuxa,
	qvstfcsuxi,
	qvstfcsuxia,
	qvstfcsx,
	qvstfcsxa,
	qvstfcsxi,
	qvstfcsxia,
	qvstfdux,
	qvstfduxa,
	qvstfduxi,
	qvstfduxia,
	qvstfdx,
	qvstfdxa,
	qvstfdxi,
	qvstfdxia,
	qvstfiwx,
	qvstfiwxa,
	qvstfsux,
	qvstfsuxa,
	qvstfsuxi,
	qvstfsuxia,
	qvstfsx,
	qvstfsxa,
	qvstfsxi,
	qvstfsxia,
	rfci,
	rfdi,
	rfi,
	rfid,
	rfmci,
	rldcl,
	rldcr,
	rldic,
	rldicl,
	rldicr,
	rldimi,
	rlwimi,
	rlwinm,
	rlwnm,
	sc,
	slbia,
	slbie,
	slbmfee,
	slbmte,
	sld,
	slw,
	srad,
	sradi,
	sraw,
	srawi,
	srd,
	srw,
	stb,
	stbcix,
	stbu,
	stbux,
	stbx,
	std,
	stdbrx,
	stdcix,
	stdcx,
	stdu,
	stdux,
	stdx,
	stfd,
	stfdu,
	stfdux,
	stfdx,
	stfiwx,
	stfs,
	stfsu,
	stfsux,
	stfsx,
	sth,
	sthbrx,
	sthcix,
	sthu,
	sthux,
	sthx,
	stmw,
	stswi,
	stvebx,
	stvehx,
	stvewx,
	stvx,
	stvxl,
	stw,
	stwbrx,
	stwcix,
	stwcx,
	stwu,
	stwux,
	stwx,
	stxsdx,
	stxvd2x,
	stxvw4x,
	subf,
	subfc,
	subfe,
	subfic,
	subfme,
	subfze,
	sync,
	td,
	tdi,
	tlbia,
	tlbie,
	tlbiel,
	tlbivax,
	tlbld,
	tlbli,
	tlbre,
	tlbsx,
	tlbsync,
	tlbwe,
	trap,
	tw,
	twi,
	vaddcuw,
	vaddfp,
	vaddsbs,
	vaddshs,
	vaddsws,
	vaddubm,
	vaddubs,
	vaddudm,
	vadduhm,
	vadduhs,
	vadduwm,
	vadduws,
	vand,
	vandc,
	vavgsb,
	vavgsh,
	vavgsw,
	vavgub,
	vavguh,
	vavguw,
	vcfsx,
	vcfux,
	vclzb,
	vclzd,
	vclzh,
	vclzw,
	vcmpbfp,
	vcmpeqfp,
	vcmpequb,
	vcmpequd,
	vcmpequh,
	vcmpequw,
	vcmpgefp,
	vcmpgtfp,
	vcmpgtsb,
	vcmpgtsd,
	vcmpgtsh,
	vcmpgtsw,
	vcmpgtub,
	vcmpgtud,
	vcmpgtuh,
	vcmpgtuw,
	vctsxs,
	vctuxs,
	veqv,
	vexptefp,
	vlogefp,
	vmaddfp,
	vmaxfp,
	vmaxsb,
	vmaxsd,
	vmaxsh,
	vmaxsw,
	vmaxub,
	vmaxud,
	vmaxuh,
	vmaxuw,
	vmhaddshs,
	vmhraddshs,
	vminud,
	vminfp,
	vminsb,
	vminsd,
	vminsh,
	vminsw,
	vminub,
	vminuh,
	vminuw,
	vmladduhm,
	vmrghb,
	vmrghh,
	vmrghw,
	vmrglb,
	vmrglh,
	vmrglw,
	vmsummbm,
	vmsumshm,
	vmsumshs,
	vmsumubm,
	vmsumuhm,
	vmsumuhs,
	vmulesb,
	vmulesh,
	vmulesw,
	vmuleub,
	vmuleuh,
	vmuleuw,
	vmulosb,
	vmulosh,
	vmulosw,
	vmuloub,
	vmulouh,
	vmulouw,
	vmuluwm,
	vnand,
	vnmsubfp,
	vnor,
	vor,
	vorc,
	vperm,
	vpkpx,
	vpkshss,
	vpkshus,
	vpkswss,
	vpkswus,
	vpkuhum,
	vpkuhus,
	vpkuwum,
	vpkuwus,
	vpopcntb,
	vpopcntd,
	vpopcnth,
	vpopcntw,
	vrefp,
	vrfim,
	vrfin,
	vrfip,
	vrfiz,
	vrlb,
	vrld,
	vrlh,
	vrlw,
	vrsqrtefp,
	vsel,
	vsl,
	vslb,
	vsld,
	vsldoi,
	vslh,
	vslo,
	vslw,
	vspltb,
	vsplth,
	vspltisb,
	vspltish,
	vspltisw,
	vspltw,
	vsr,
	vsrab,
	vsrad,
	vsrah,
	vsraw,
	vsrb,
	vsrd,
	vsrh,
	vsro,
	vsrw,
	vsubcuw,
	vsubfp,
	vsubsbs,
	vsubshs,
	vsubsws,
	vsububm,
	vsububs,
	vsubudm,
	vsubuhm,
	vsubuhs,
	vsubuwm,
	vsubuws,
	vsum2sws,
	vsum4sbs,
	vsum4shs,
	vsum4ubs,
	vsumsws,
	vupkhpx,
	vupkhsb,
	vupkhsh,
	vupklpx,
	vupklsb,
	vupklsh,
	vxor,
	wait,
	wrtee,
	wrteei,
	xor,
	xori,
	xoris,
	xsabsdp,
	xsadddp,
	xscmpodp,
	xscmpudp,
	xscpsgndp,
	xscvdpsp,
	xscvdpsxds,
	xscvdpsxws,
	xscvdpuxds,
	xscvdpuxws,
	xscvspdp,
	xscvsxddp,
	xscvuxddp,
	xsdivdp,
	xsmaddadp,
	xsmaddmdp,
	xsmaxdp,
	xsmindp,
	xsmsubadp,
	xsmsubmdp,
	xsmuldp,
	xsnabsdp,
	xsnegdp,
	xsnmaddadp,
	xsnmaddmdp,
	xsnmsubadp,
	xsnmsubmdp,
	xsrdpi,
	xsrdpic,
	xsrdpim,
	xsrdpip,
	xsrdpiz,
	xsredp,
	xsrsqrtedp,
	xssqrtdp,
	xssubdp,
	xstdivdp,
	xstsqrtdp,
	xvabsdp,
	xvabssp,
	xvadddp,
	xvaddsp,
	xvcmpeqdp,
	xvcmpeqsp,
	xvcmpgedp,
	xvcmpgesp,
	xvcmpgtdp,
	xvcmpgtsp,
	xvcpsgndp,
	xvcpsgnsp,
	xvcvdpsp,
	xvcvdpsxds,
	xvcvdpsxws,
	xvcvdpuxds,
	xvcvdpuxws,
	xvcvspdp,
	xvcvspsxds,
	xvcvspsxws,
	xvcvspuxds,
	xvcvspuxws,
	xvcvsxddp,
	xvcvsxdsp,
	xvcvsxwdp,
	xvcvsxwsp,
	xvcvuxddp,
	xvcvuxdsp,
	xvcvuxwdp,
	xvcvuxwsp,
	xvdivdp,
	xvdivsp,
	xvmaddadp,
	xvmaddasp,
	xvmaddmdp,
	xvmaddmsp,
	xvmaxdp,
	xvmaxsp,
	xvmindp,
	xvminsp,
	xvmsubadp,
	xvmsubasp,
	xvmsubmdp,
	xvmsubmsp,
	xvmuldp,
	xvmulsp,
	xvnabsdp,
	xvnabssp,
	xvnegdp,
	xvnegsp,
	xvnmaddadp,
	xvnmaddasp,
	xvnmaddmdp,
	xvnmaddmsp,
	xvnmsubadp,
	xvnmsubasp,
	xvnmsubmdp,
	xvnmsubmsp,
	xvrdpi,
	xvrdpic,
	xvrdpim,
	xvrdpip,
	xvrdpiz,
	xvredp,
	xvresp,
	xvrspi,
	xvrspic,
	xvrspim,
	xvrspip,
	xvrspiz,
	xvrsqrtedp,
	xvrsqrtesp,
	xvsqrtdp,
	xvsqrtsp,
	xvsubdp,
	xvsubsp,
	xvtdivdp,
	xvtdivsp,
	xvtsqrtdp,
	xvtsqrtsp,
	xxland,
	xxlandc,
	xxleqv,
	xxlnand,
	xxlnor,
	xxlor,
	xxlorc,
	xxlxor,
	xxmrghw,
	xxmrglw,
	xxpermdi,
	xxsel,
	xxsldwi,
	xxspltw,
	bca,
	bcla,

	// Extra & alias instructions
	slwi,
	srwi,
	sldi,

	bta,
	crset,
	crnot,
	crmove,
	crclr,
	mfbr0,
	mfbr1,
	mfbr2,
	mfbr3,
	mfbr4,
	mfbr5,
	mfbr6,
	mfbr7,
	mfxer,
	mfrtcu,
	mfrtcl,
	mfdscr,
	mfdsisr,
	mfdar,
	mfsrr2,
	mfsrr3,
	mfcfar,
	mfamr,
	mfpid,
	mftblo,
	mftbhi,
	mfdbatu,
	mfdbatl,
	mfibatu,
	mfibatl,
	mfdccr,
	mficcr,
	mfdear,
	mfesr,
	mfspefscr,
	mftcr,
	mfasr,
	mfpvr,
	mftbu,
	mtcr,
	mtbr0,
	mtbr1,
	mtbr2,
	mtbr3,
	mtbr4,
	mtbr5,
	mtbr6,
	mtbr7,
	mtxer,
	mtdscr,
	mtdsisr,
	mtdar,
	mtsrr2,
	mtsrr3,
	mtcfar,
	mtamr,
	mtpid,
	mttbl,
	mttbu,
	mttblo,
	mttbhi,
	mtdbatu,
	mtdbatl,
	mtibatu,
	mtibatl,
	mtdccr,
	mticcr,
	mtdear,
	mtesr,
	mtspefscr,
	mttcr,
	not,
	mr,
	rotld,
	rotldi,
	clrldi,
	rotlwi,
	clrlwi,
	rotlw,
	sub,
	subc,
	lwsync,
	ptesync,
	tdlt,
	tdeq,
	tdgt,
	tdne,
	tdllt,
	tdlgt,
	tdu,
	tdlti,
	tdeqi,
	tdgti,
	tdnei,
	tdllti,
	tdlgti,
	tdui,
	tlbrehi,
	tlbrelo,
	tlbwehi,
	tlbwelo,
	twlt,
	tweq,
	twgt,
	twne,
	twllt,
	twlgt,
	twu,
	twlti,
	tweqi,
	twgti,
	twnei,
	twllti,
	twlgti,
	twui,
	waitrsv,
	waitimpl,
	xnop,
	xvmovdp,
	xvmovsp,
	xxspltd,
	xxmrghd,
	xxmrgld,
	xxswapd,
	bt,
	bf,
	bdnzt,
	bdnzf,
	bdzf,
	bdzt,
	bfa,
	bdnzta,
	bdnzfa,
	bdzta,
	bdzfa,
	btctr,
	bfctr,
	btctrl,
	bfctrl,
	btl,
	bfl,
	bdnztl,
	bdnzfl,
	bdztl,
	bdzfl,
	btla,
	bfla,
	bdnztla,
	bdnzfla,
	bdztla,
	bdzfla,
	btlr,
	bflr,
	bdnztlr,
	bdztlr,
	bdzflr,
	btlrl,
	bflrl,
	bdnztlrl,
	bdnzflrl,
	bdztlrl,
	bdzflrl,

	// QPX
	qvfand,
	qvfclr,
	qvfandc,
	qvfctfb,
	qvfxor,
	qvfor,
	qvfnor,
	qvfequ,
	qvfnot,
	qvforc,
	qvfnand,
	qvfset,
}

/// Group of PPC instructions
enum PpcInstructionGroup {
	invalid = 0,

	// Generic groups
	// all jump instructions (conditional+direct+indirect jumps)
	JUMP,

	// Architecture-specific groups
	altivec = 128,
	mode32,
	mode64,
	booke,
	notbooke,
	spe,
	vsx,
	e500,
	ppc4xx,
	ppc6xx,
	icbt,
	p8altivec,
	p8vector,
	qpx,
}