/****** Object:  StoredProcedure [dbo].[CFOB_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CFOB_RETRIEVE_S1] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ac_StatusChange_CODE      CHAR(1) OUTPUT,
 @Ac_CaseNew_ID             CHAR(15) OUTPUT,
 @As_InfoLine1_TEXT         VARCHAR(80) OUTPUT,
 @As_InfoLine2_TEXT         VARCHAR(80) OUTPUT,
 @As_InfoLine3_TEXT         VARCHAR(80) OUTPUT,
 @As_InfoLine4_TEXT         VARCHAR(80) OUTPUT,
 @As_InfoLine5_TEXT         VARCHAR(80) OUTPUT,
 @Ad_ActionResolution_DATE  DATE OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CFOB_RETRIEVE_S1    
  *     DESCRIPTION       : Retrieve Csenet Information Block details for a Transaction Header Idno, Transaction Date, and Other State Fips.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SELECT @Ac_StatusChange_CODE = NULL,
         @Ac_CaseNew_ID = NULL,
         @As_InfoLine1_TEXT = NULL,
         @As_InfoLine2_TEXT = NULL,
         @As_InfoLine3_TEXT = NULL,
         @As_InfoLine4_TEXT = NULL,
         @As_InfoLine5_TEXT = NULL;

  SELECT @Ac_StatusChange_CODE = CF.StatusChange_CODE,
         @Ac_CaseNew_ID = CF.CaseNew_ID,
         @As_InfoLine1_TEXT = CF.InfoLine1_TEXT,
         @As_InfoLine2_TEXT = CF.InfoLine2_TEXT,
         @As_InfoLine3_TEXT = CF.InfoLine3_TEXT,
         @As_InfoLine4_TEXT = CF.InfoLine4_TEXT,
         @As_InfoLine5_TEXT = CF.InfoLine5_TEXT,
         @Ad_ActionResolution_DATE = CT.ActionResolution_DATE
    FROM CFOB_Y1 CF
         LEFT OUTER JOIN CTHB_Y1 CT
          ON (CF.TransHeader_IDNO = CT.TransHeader_IDNO
              AND CF.Transaction_DATE = CT.Transaction_DATE
              AND CF.IVDOutOfStateFips_CODE = CT.IVDOutOfStateFips_CODE)
   WHERE CF.TransHeader_IDNO = @An_TransHeader_IDNO
     AND CF.Transaction_DATE = @Ad_Transaction_DATE
     AND CF.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;
 END; --End of CFOB_RETRIEVE_S1

GO
