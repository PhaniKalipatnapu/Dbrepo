/****** Object:  StoredProcedure [dbo].[CERR_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CERR_RETRIEVE_S6] (
 @An_SeqError_IDNO         NUMERIC(6, 0),
 @An_TransHeader_IDNO      NUMERIC(12,0),
 @Ac_Fips_CODE             CHAR(7) OUTPUT,
 @Ac_OtherFips_CODE        CHAR(7) OUTPUT,
 @An_Case_IDNO             NUMERIC(6, 0) OUTPUT,
 @Ac_OutStateCase_ID       CHAR(15) OUTPUT,
 @Ad_Transaction_DATE      DATE OUTPUT,
 @Ac_Action_CODE           CHAR(1) OUTPUT,
 @Ac_Function_CODE         CHAR(3) OUTPUT,
 @Ac_Reason_CODE           CHAR(5) OUTPUT,
 @Ac_Error_CODE            CHAR(4) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(41) OUTPUT,
 @Ad_Update_DTTM           DATETIME2 OUTPUT,
 @As_DescriptionFar_TEXT   VARCHAR(1000) OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : CERR_RETRIEVE_S6      
  *     DESCRIPTION       : Retrieve Csenet Host Error details for a Function Code, Action Code, Reason Code and Sequence Error Idno.      
  *     DEVELOPED BY      : IMP Team      
  *     DEVELOPED ON      : 01-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
  */
 BEGIN
  SELECT @Ac_Fips_CODE = NULL,
         @Ac_OtherFips_CODE = NULL,
         @An_Case_IDNO = NULL,
         @Ac_OutStateCase_ID = NULL,
         @Ad_Transaction_DATE = NULL,
         @Ac_Action_CODE = NULL,
         @Ac_Function_CODE = NULL,
         @Ac_Reason_CODE = NULL,
         @Ac_Error_CODE = NULL,
         @As_DescriptionError_TEXT = NULL,
         @Ad_Update_DTTM = NULL,
         @As_DescriptionFar_TEXT = NULL;

  SELECT @Ac_Fips_CODE = a.Fips_CODE,
         @Ac_OtherFips_CODE = a.OtherFips_CODE,
         @An_Case_IDNO = a.Case_IDNO,
         @Ac_OutStateCase_ID = a.OutStateCase_ID,
         @Ad_Transaction_DATE = a.Transaction_DATE,
         @Ac_Action_CODE = a.Action_CODE,
         @Ac_Function_CODE = a.Function_CODE,
         @Ac_Reason_CODE = a.Reason_CODE,
         @Ac_Error_CODE = a.Error_CODE,
         @As_DescriptionError_TEXT = a.DescriptionError_TEXT,
         @Ad_Update_DTTM = a.Update_DTTM,
         @As_DescriptionFar_TEXT = b.DescriptionFar_TEXT
    FROM CERR_Y1 a
         JOIN CFAR_Y1 b
          ON b.Action_CODE = a.Action_CODE
             AND b.Function_CODE = a.Function_CODE
             AND b.Reason_CODE = a.Reason_CODE
   WHERE a.SeqError_IDNO = @An_SeqError_IDNO
       AND a.TransHeader_IDNO=@An_TransHeader_IDNO ;
 END; --End of CERR_RETRIEVE_S6  


GO
