/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S11] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMajorNext_CODE CHAR(4),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Notice_ID              CHAR(8),
 @Ac_Recipient_CODE         CHAR(2),
 @Ac_TypeService_CODE       CHAR(2),
 @Ac_Exists_INDC            CHAR(1) OUTPUT
 )
AS
 /*                                                                                                                               
  *     PROCEDURE NAME    : AFMS_RETRIEVE_S11                                                                                     
  *     DESCRIPTION       : Returns 1 if the recipients already exists for a document i.e. for the given Major and Minor Activity.
  *     DEVELOPED BY      : IMP Team                                                                                              
  *     DEVELOPED ON      : 05-AUG-2011                                                                                           
  *     MODIFIED BY       :                                                                                                       
  *     MODIFIED ON       :                                                                                                       
  *     VERSION NO        : 1                                                                                                     
 */
 BEGIN
  
  DECLARE
   @Lc_No_TEXT	CHAR(1)	= 'N',
   @Lc_Yes_TEXT	CHAR(1)	= 'Y', 
   @Ld_High_DATE DATE = '12/31/9999';

   SET @Ac_Exists_INDC = @Lc_No_TEXT;
    
  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM AFMS_Y1 A
   WHERE A.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND A.Reason_CODE = @Ac_Reason_CODE
     AND A.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND A.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND A.Notice_ID = @Ac_Notice_ID
     AND A.Recipient_CODE = @Ac_Recipient_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.TypeService_CODE = @Ac_TypeService_CODE;
 END; --End of AFMS_RETRIEVE_S11 

GO
