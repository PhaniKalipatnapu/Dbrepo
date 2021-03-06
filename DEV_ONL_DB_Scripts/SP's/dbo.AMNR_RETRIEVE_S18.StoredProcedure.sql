/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S18] (
 @Ac_ActivityMinor_CODE        CHAR(5),
 @Ac_TypeActivity_CODE         CHAR(1) OUTPUT,
 @Ac_TypeLocation1_CODE        CHAR(1) OUTPUT,
 @Ac_TypeLocation2_CODE        CHAR(1) OUTPUT,
 @As_DescriptionActivity_TEXT  VARCHAR(75) OUTPUT
 )
AS
 /*                                                                                                                                                                        
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S18                                                                                                                               
  *     DESCRIPTION       : Retrieve the Location Types where the appointment has to be conducted and for a Minor Activity code.            
  *     DEVELOPED BY      : IMP Team                                                                                                                                     
  *     DEVELOPED ON      : 22-AUG-2011                                                                                                                                   
  *     MODIFIED BY       :                                                                                                                                                
  *     MODIFIED ON       :                                                                                                                                                
  *     VERSION NO        : 1                                                                                                                                              
 */
 BEGIN
  SELECT @Ac_TypeLocation1_CODE = NULL,
         @Ac_TypeLocation2_CODE = NULL,
         @Ac_TypeActivity_CODE = NULL,
         @As_DescriptionActivity_TEXT = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_TypeLocation1_CODE = A.TypeLocation1_CODE,
         @Ac_TypeLocation2_CODE = A.TypeLocation2_CODE,
         @Ac_TypeActivity_CODE = A.TypeActivity_CODE,
         @As_DescriptionActivity_TEXT = A.DescriptionActivity_TEXT
    FROM AMNR_Y1 A
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF AMNR_RETRIEVE_S18                                                                                                                                                                      


GO
