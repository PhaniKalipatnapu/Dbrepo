/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S12] (
 @Ac_Process_ID               CHAR(10),
 @Ac_Type_CODE                CHAR(5),
 @Ac_Reason_CODE              CHAR(5),
 @As_DescriptionActivity_TEXT VARCHAR(75) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RESF_RETRIEVE_S12
  *     DESCRIPTION       : Retrieve the Description of a Minor Activity for a Process Number. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_DescriptionActivity_TEXT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @As_DescriptionActivity_TEXT = A.DescriptionActivity_TEXT
    FROM RESF_Y1 R
         JOIN AMNR_Y1 A
          ON A.ActivityMinor_CODE = R.Reason_CODE
   WHERE R.Process_ID = @Ac_Process_ID
     AND R.Type_CODE = @Ac_Type_CODE
     AND R.Reason_CODE = @Ac_Reason_CODE
     AND A.ActivityMinor_CODE = R.Reason_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF RESF_RETRIEVE_S12


GO
