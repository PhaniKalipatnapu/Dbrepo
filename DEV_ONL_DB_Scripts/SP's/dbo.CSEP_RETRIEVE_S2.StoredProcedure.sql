/****** Object:  StoredProcedure [dbo].[CSEP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CSEP_RETRIEVE_S2] (
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Function_CODE          CHAR(3),
 @Ac_CertMode_INDC          CHAR(1),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CSEP_RETRIEVE_S2
  *     DESCRIPTION       : Retrieves the Row Count For a Given State and CSENet Function
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CSEP_Y1 C
   WHERE C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.Function_CODE = @Ac_Function_CODE
     AND C.CertMode_INDC <> ISNULL(@Ac_CertMode_INDC, C.CertMode_INDC)
     AND C.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF CSEP_RETRIEVE_S2


GO
