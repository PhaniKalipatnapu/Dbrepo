/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S12] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S12
  *     DESCRIPTION       : Retrieve Distinct Notice Idno and Description for a Notice Idno.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE               DATE = '12/31/9999',
          @Lc_PrintmethodCentral_CODE CHAR(1) = 'C';

  SELECT DISTINCT f.Notice_ID
    FROM FFCL_Y1 f
         JOIN NREP_Y1 n
          ON f.Notice_ID = n.Notice_ID
   WHERE f.Function_CODE = @Ac_Function_CODE
     AND f.Action_CODE = @Ac_Action_CODE
     AND f.Reason_CODE = @Ac_Reason_CODE
     AND n.Printmethod_CODE = @Lc_PrintmethodCentral_CODE
     AND f.EndValidity_DATE = @Ld_High_DATE
     AND n.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of FFCL_RETRIEVE_S12

GO
