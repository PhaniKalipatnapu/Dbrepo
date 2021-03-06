/****** Object:  StoredProcedure [dbo].[CPTB_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPTB_RETRIEVE_S1](
 @Ac_Relationship_CODE      CHAR(1),
 @Ad_Transaction_DATE       DATE,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @An_TransHeader_IDNO       NUMERIC(12, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CPTB_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Csenet Participant Block details for the Transaction Header, State FIPS, Transaction Date, Member Case Relationship in Csenet Participant Block, Csenet Trans Header Block and Csenet Case Data Block.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE 
          @Lc_Null_TEXT                     CHAR(1) = '',
          @Lc_IndInboundOutbound_CODE       CHAR(1) = 'I',
          @Ls_IndChildPaternityStat_NAME    VARCHAR(50) = 'ChildPaternityStatus_CODE',
          @Ls_PartBlockName_NAME            VARCHAR(50) = 'PARTICIPANT_DATA_BLOCKS';

  SELECT C.Last_NAME,
         C.First_NAME,
         C.Middle_NAME,
         C.Suffix_NAME,
         C.Birth_DATE,
         C.MemberSsn_NUMB,
         C.MemberSex_CODE,
         C.Race_CODE,
         C.ChildRelationshipNcp_CODE,
         C.ParticipantLine1_ADDR,
         C.ParticipantLine2_ADDR,
         C.ParticipantCity_ADDR,
         C.ParticipantState_ADDR,
         C.ParticipantZip_ADDR,
		 C.EinEmployer_ID,
         C.Employer_NAME,
         C.EmployerLine1_ADDR,
         C.EmployerLine2_ADDR,
         C.EmployerCity_ADDR,
         C.EmployerState_ADDR,
         C.EmployerZip_ADDR,
         C.PlaceOfBirth_NAME,
         SUBSTRING(ISNULL(C3.InState_CODE,C.ChildPaternityStatus_CODE), 1, 1) AS ChildPaternityStatus_CODE,
         SUBSTRING(ISNULL(C3.InState_CODE,C.ChildPaternityStatus_CODE), 2, 2) AS PaternityEst_CODE,
         C1.Transaction_DATE,
         C2.NondisclosureFinding_INDC
    FROM CPTB_Y1 C
    		LEFT OUTER JOIN 
    	 CSEC_Y1 C3
    	 	ON (C3.Csenet_CODE = C.ChildPaternityStatus_CODE
    	 		AND C3.Block_NAME = @Ls_PartBlockName_NAME
    	 		AND C3.Field_NAME = @Ls_IndChildPaternityStat_NAME
    	 		AND C3.InboundOutbound_CODE = @Lc_IndInboundOutbound_CODE)
    		JOIN
         CTHB_Y1 C1
         ON (C.TransHeader_IDNO = @An_TransHeader_IDNO)
         	JOIN
         CSDB_Y1 C2
         ON (C1.TransHeader_IDNO = @An_TransHeader_IDNO)         
   WHERE 
     C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.Transaction_DATE = @Ad_Transaction_DATE
     AND C.Relationship_CODE = @Ac_Relationship_CODE
     AND C1.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C1.Transaction_DATE = @Ad_Transaction_DATE
     AND C2.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C2.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C2.Transaction_DATE = @Ad_Transaction_DATE;
     
 END;--End of CPTB_RETRIEVE_S1


GO
