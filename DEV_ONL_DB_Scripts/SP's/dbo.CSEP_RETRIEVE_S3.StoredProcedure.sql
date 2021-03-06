/****** Object:  StoredProcedure [dbo].[CSEP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSEP_RETRIEVE_S3] (
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Function_CODE          CHAR(3),
 @Ac_CertMode_INDC          CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSEP_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve Transaction sequence and the indicator if this function is used for communication with the other state or not for a Function Code and Other State Fips Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 13-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ac_CertMode_INDC = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_CertMode_INDC = c.CertMode_INDC
    FROM CSEP_Y1 c
   WHERE c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND c.Function_CODE = @Ac_Function_CODE
     AND c.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of CSEP_RETRIEVE_S3

GO
