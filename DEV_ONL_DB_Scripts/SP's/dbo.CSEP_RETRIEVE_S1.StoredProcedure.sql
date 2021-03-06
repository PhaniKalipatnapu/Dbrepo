/****** Object:  StoredProcedure [dbo].[CSEP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSEP_RETRIEVE_S1] (
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @Ac_Function_CODE            CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_CertMode_INDC            CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSEP_RETRIEVE_S1
  *     DESCRIPTION       : Gets the Trasaction Code and Y or N depending on whether the CSENet Function is used for communication with the other state or not 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_CertMode_INDC = NULL,
         @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT @Ac_CertMode_INDC = C.CertMode_INDC,
         @An_TransactionEventSeq_NUMB = C.TransactionEventSeq_NUMB
    FROM CSEP_Y1 C
         JOIN FIPS_Y1 F
          ON C.IVDOutOfStateFips_CODE = F.StateFips_CODE
   WHERE C.Function_CODE = @Ac_Function_CODE
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.EndValidity_DATE = @Ld_High_DATE
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF CSEP_RETRIEVE_S1


GO
