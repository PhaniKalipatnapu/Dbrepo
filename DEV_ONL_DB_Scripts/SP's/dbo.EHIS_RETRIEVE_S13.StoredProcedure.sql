/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S13]  (
     @An_Case_IDNO		 NUMERIC(6,0),
     @An_MemberMci_IDNO	 NUMERIC(10,0)	 OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : EHIS_RETRIEVE_S13
 *     DESCRIPTION       : Retieving the Member Mci Id for the given Case id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/17/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */
 BEGIN
      SET @An_MemberMci_IDNO = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE            CHAR(1) 	 = 'C', 
          @Lc_CaseRelationshipNcp_CODE           CHAR(1) 	 = 'A', 
          @Lc_CaseRelationshipPutFather_CODE     CHAR(1) 	 = 'P', 
          @Lc_CaseMemberStatusActive_CODE        CHAR(1)     = 'A', 
          @Lc_StatusYes_CODE                     CHAR(1)     = 'Y', 
          @Ln_MemberMci_IDNO                     NUMERIC(7)  = 9999999,
          @Ld_High_DATE                          DATE        = '12/31/9999', 
          @Ld_Current_DATE                       DATE        = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_MajorActivityCase_CODE             CHAR(4)     = 'CASE', 
          @Lc_ActivityMinorNopri_CODE            CHAR(5)     = 'NOPRI', 
          @Lc_SubsystemEnforcement_CODE          CHAR(2)     = 'EN', 
          @Lc_NoticeEnf14_ID                     CHAR(6)     = 'ENF-14', 
          @Lc_TypeIncomeMilitary_CODE            CHAR(2)     = 'ML';
       
   SELECT @An_MemberMci_IDNO = MAX(e.MemberMci_IDNO)
     FROM EHIS_Y1  e
    WHERE e.MemberMci_IDNO IN( SELECT C.MemberMci_IDNO
				                 FROM CMEM_Y1 C
				                WHERE C.Case_IDNO = @An_Case_IDNO 
					              AND C.CaseRelationship_CODE IN ( @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE ) 
					              AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) 
	  AND e.TypeIncome_CODE = @Lc_TypeIncomeMilitary_CODE 
	  AND @Ld_Current_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE 
	  AND e.Status_CODE = @Lc_StatusYes_CODE 
	  AND e.EndEmployment_DATE = @Ld_High_DATE 
	  AND NOT EXISTS(SELECT 1 
				       FROM NMRQ_Y1 N
				      WHERE N.Case_IDNO = @An_Case_IDNO 
				        AND N.Notice_ID = @Lc_NoticeEnf14_ID) 
	  AND EXISTS(SELECT 1 
				   FROM CMEM_Y1 C
				  WHERE C.Case_IDNO             = @An_Case_IDNO 
					AND C.MemberMci_IDNO       <> @Ln_MemberMci_IDNO 
					AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
					AND C.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE) 
		AND NOT EXISTS (SELECT 1 
				          FROM FORM_Y1 F
				         WHERE F.Notice_ID = @Lc_NoticeEnf14_ID 
					       AND F.Topic_IDNO IN(SELECT d.Topic_IDNO
												 FROM DMNR_Y1  d
												WHERE d.Case_IDNO = @An_Case_IDNO  
												  AND d.ActivityMajor_CODE = @Lc_MajorActivityCase_CODE  
												  AND d.ActivityMinor_CODE = @Lc_ActivityMinorNopri_CODE  
												  AND d.Subsystem_CODE     = @Lc_SubsystemEnforcement_CODE));

END;--END OF EHIS_RETRIEVE_S13

GO
