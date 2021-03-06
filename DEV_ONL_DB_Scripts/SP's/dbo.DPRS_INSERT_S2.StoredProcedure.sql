/****** Object:  StoredProcedure [dbo].[DPRS_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DPRS_INSERT_S2]  
(
	 @An_Case_IDNO					CHAR(6),
     @Ac_File_ID		 			CHAR(10),
     @An_County_IDNO		 		NUMERIC(3),
     @An_TransactionEventSeq_NUMB	NUMERIC(19),
     @Ac_SignedOnWorker_ID		 	CHAR(30),
	 @Ad_EffectiveStart_DATE		DATE,
     @As_AttorneyAttn_NAME		 	VARCHAR(60),
	 @An_AssociatedMemberMci_IDNO	NUMERIC(10)             
)
AS

/*
 *     PROCEDURE NAME    : DPRS_INSERT_S2
 *     DESCRIPTION       : INSERT Member details into Docket Persons table when the person is not present.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 05-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
  BEGIN

     DECLARE @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A',
     		 @Lc_CaseRelationShipNcp_CODE		CHAR(1) = 'A',
			 @Lc_CaseRelationShipCp_CODE		CHAR(1) = 'C',
			 @Lc_CaseRelationShipDp_CODE		CHAR(1) = 'D',
			 @Lc_CaseRelationShipPf_CODE		CHAR(1) = 'P',
			 @Lc_TypePersonCp_CODE				CHAR(2) = 'CP',
			 @Lc_TypePersonDp_CODE				CHAR(2) = 'CI',
			 @Lc_TypePersonNcp_CODE				CHAR(3) = 'NCP',			 
             @Ld_High_DATE 						DATE = '12/31/9999',
             @Ld_System_DTTM					DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
             
	INSERT DPRS_Y1	
	SELECT @Ac_File_ID,
			@An_County_IDNO,
			t.TypePerson_CODE,
			t.DocketPerson_IDNO,
			@Ac_SignedOnWorker_ID,
			d.FullDisplay_NAME AS File_NAME,
			@Ad_EffectiveStart_DATE,
			@Ld_High_DATE,
			@Ld_System_DTTM,
			@Ld_High_DATE,
			@An_TransactionEventSeq_NUMB,
			@Ld_System_DTTM,
			@As_AttorneyAttn_NAME,
			@An_AssociatedMemberMci_IDNO	
	FROM DEMO_Y1 d,		
	( SELECT CASE WHEN c.CaseRelationShip_CODE = @Lc_CaseRelationShipCp_CODE
				THEN @Lc_TypePersonCp_CODE
				WHEN c.CaseRelationShip_CODE IN (@Lc_CaseRelationShipNcp_CODE, @Lc_CaseRelationShipPf_CODE)
				THEN @Lc_TypePersonNcp_CODE
				WHEN c.CaseRelationShip_CODE = @Lc_CaseRelationShipDp_CODE
				THEN @Lc_TypePersonDp_CODE
				END TypePerson_CODE,
			c.MemberMci_IDNO AS DocketPerson_IDNO
	FROM CMEM_Y1 c
	WHERE c.Case_IDNO = @An_Case_IDNO
	AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
	AND c.CaseRelationShip_CODE IN ( @Lc_CaseRelationShipCp_CODE, @Lc_CaseRelationShipNcp_CODE, @Lc_CaseRelationShipPf_CODE, @Lc_CaseRelationShipDp_CODE ) ) AS t
	WHERE NOT EXISTS ( SELECT 1
									FROM DPRS_Y1 p
									WHERE p.File_ID = @Ac_File_ID
									AND p.TypePerson_CODE = t.TypePerson_CODE
									AND p.DocketPerson_IDNO = t.DocketPerson_IDNO
									AND p.EffectiveEnd_DATE = @Ld_High_DATE
									AND p.EndValidity_DATE = @Ld_High_DATE )	
	AND d.MemberMci_IDNO = t.DocketPerson_IDNO									
                  
END;  -- END OF DPRS_INSERT_S2


GO
