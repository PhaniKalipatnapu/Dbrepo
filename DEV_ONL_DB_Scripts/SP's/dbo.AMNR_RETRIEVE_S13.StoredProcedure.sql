/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S13] (
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_TypeActivity_CODE        CHAR(1) OUTPUT,
 @As_DescriptionActivity_TEXT VARCHAR(75) OUTPUT,
 @An_DayToComplete_QNTY       NUMERIC(3, 0) OUTPUT,
 @Ac_ActionAlert_CODE         CHAR(1) OUTPUT,
 @Ac_Element_ID               CHAR(10) OUTPUT,
 @An_DayAlertWarn_QNTY        NUMERIC(3, 0) OUTPUT,
 @Ac_MemberCombinations_CODE  CHAR(1) OUTPUT,
 @Ac_TypeLocation1_CODE       CHAR(1) OUTPUT,
 @Ac_TypeLocation2_CODE       CHAR(1) OUTPUT,
 @Ac_BusinessDays_INDC        CHAR(1) OUTPUT,
 @Ac_CaseJournal_INDC         CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S13   
  *     DESCRIPTION       : Retrieve the Minor Activity Details for corresponding Minor Activity CODE 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_TypeActivity_CODE = NULL,
         @As_DescriptionActivity_TEXT = NULL,
         @An_DayToComplete_QNTY = NULL,
         @Ac_ActionAlert_CODE = NULL,
         @Ac_Element_ID = NULL,
         @An_DayAlertWarn_QNTY = NULL,
         @Ac_MemberCombinations_CODE = NULL,
         @Ac_TypeLocation1_CODE = NULL,
         @Ac_TypeLocation2_CODE = NULL,
         @Ac_BusinessDays_INDC = NULL,
         @Ac_CaseJournal_INDC = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_TypeActivity_CODE = A.TypeActivity_CODE,
         @As_DescriptionActivity_TEXT = A.DescriptionActivity_TEXT,
         @An_DayToComplete_QNTY = A.DayToComplete_QNTY,
         @Ac_ActionAlert_CODE = A.ActionAlert_CODE,
         @Ac_Element_ID = A.Element_ID,
         @An_DayAlertWarn_QNTY = A.DayAlertWarn_QNTY,
         @Ac_MemberCombinations_CODE = A.MemberCombinations_CODE,
         @Ac_TypeLocation1_CODE = A.TypeLocation1_CODE,
         @Ac_TypeLocation2_CODE = A.TypeLocation2_CODE,
         @Ac_BusinessDays_INDC = A.BusinessDays_INDC,
         @Ac_CaseJournal_INDC = A.CaseJournal_INDC
    FROM AMNR_Y1 A
   WHERE A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF AMNR_RETRIEVE_S13  

GO
