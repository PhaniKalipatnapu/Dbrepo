/****** Object:  StoredProcedure [dbo].[BSACS_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BSACS_INSERT_S1]
(
	@An_Case_IDNO					NUMERIC(6,0),
	@Ac_StatusCase_CODE				CHAR(1),
	@Ac_TypeCase_CODE				CHAR(1),
	@Ac_RespondInit_CODE			CHAR(1),
	@Ac_TypeEstablish_CODE			CHAR(1),
	@An_County_IDNO					NUMERIC(3,0),
	@Ac_County_NAME					CHAR(40),
	@An_MemberMci_IDNO				NUMERIC(10,0),
	@Ac_First_NAME					CHAR(16),
	@Ac_Last_NAME					CHAR(20),
	@An_CpMci_IDNO					NUMERIC(10,0),
	@Ac_FirstCp_NAME				CHAR(16),
	@Ac_LastCp_NAME					CHAR(20),
	@Ac_Worker_ID					CHAR(30),
	@Ac_CaseClosure_INDC			CHAR(1),
	@Ac_Establishment_INDC			CHAR(1),
	@Ac_SecEnfmedical_INDC			CHAR(1),
	@Ac_Enfsuporder_INDC			CHAR(1),
	@Ac_Disbcollections_INDC		CHAR(1),
	@Ac_Expeditedprocess_INDC		CHAR(1),
	@Ac_ReviewAdjustment_INDC		CHAR(1),
	@Ac_InterstateIncoming_INDC		CHAR(1),
	@Ac_InterstateOutgoing_INDC		CHAR(1),
	@An_Office_IDNO					NUMERIC(3,0),
	@As_CaseTitle_NAME				VARCHAR(60),
	@Ad_Review_DATE					DATE
)
AS
/*
 *     PROCEDURE NAME    : BSACS_INSERT_S1
 *     DESCRIPTION       : This procedure is used to insert the case details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 25-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
           
	INSERT INTO BSACS_Y1
               (Case_IDNO,
                StatusCase_CODE,
                TypeCase_CODE,          
                RespondInit_CODE,
                TypeEstablish_CODE, 
                County_IDNO,
                County_NAME,
                MemberMci_IDNO,
                First_NAME,
                Last_NAME,
                CpMci_IDNO,
                FirstCp_NAME,
                LastCp_NAME,
                Worker_ID,
                CaseClosure_INDC,
                Establishment_INDC,
                SecEnfmedical_INDC,
                Enfsuporder_INDC,
                Disbcollections_INDC,
                Expeditedprocess_INDC,
                ReviewAdjustment_INDC,
                InterstateIncoming_INDC,
                InterstateOutgoing_INDC,
                Office_IDNO,
                CaseTitle_NAME,
                Review_DATE
               )
        VALUES (@An_Case_IDNO,					--Case_IDNO
                @Ac_StatusCase_CODE,			--StatusCase_CODE
                @Ac_TypeCase_CODE,				--TypeCase_CODE
                @Ac_RespondInit_CODE,			--RespondInit_CODE
                @Ac_TypeEstablish_CODE,			--Space_CODE
                @An_County_IDNO,				--County_IDNO
                @Ac_County_NAME,				--County_NAME
                @An_MemberMci_IDNO,				--MemberMci_IDNO
                @Ac_First_NAME,					--First_NAME
                @Ac_Last_NAME,					--Last_NAME
                @An_CpMci_IDNO,					--CpMci_IDNO	
                @Ac_FirstCp_NAME,				--FirstCp_NAME
                @Ac_LastCp_NAME,				--LastCp_NAME
                @Ac_Worker_ID,					--Worker_ID
                @Ac_CaseClosure_INDC,			--CaseClosure_INDC
                @Ac_Establishment_INDC,			--Establishment_INDC
                @Ac_SecEnfmedical_INDC,			--SecEnfmedical_INDC
                @Ac_Enfsuporder_INDC,			--Enfsuporder_INDC
                @Ac_Disbcollections_INDC,		--Disbcollections_INDC
                @Ac_Expeditedprocess_INDC,		--Expeditedprocess_INDC
                @Ac_ReviewAdjustment_INDC,		--ReviewAdjustment_INDC
                @Ac_InterstateIncoming_INDC,	--InterstateIncoming_INDC
                @Ac_InterstateOutgoing_INDC,	--InterstateOutgoing_INDC
                @An_Office_IDNO	,				--Office_IDNO
                @As_CaseTitle_NAME,				--CaseTitle_NAME
                @Ad_Review_DATE					--Review_DATE
                );
                
END  --END OF BSACS_INSERT_S1


GO
