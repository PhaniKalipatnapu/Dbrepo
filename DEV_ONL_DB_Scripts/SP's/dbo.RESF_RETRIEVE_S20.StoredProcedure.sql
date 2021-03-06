/****** Object:  StoredProcedure [dbo].[RESF_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RESF_RETRIEVE_S20]
(
 @Ac_Process_ID	CHAR(10), 
 @Ac_Table_ID	CHAR(4),
 @Ac_TableSub_ID CHAR(4),
 @Ac_Reason_CODE CHAR(5), 
 @Ac_Type_CODE   CHAR(5) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : RESF_RETRIEVE_S20    
  *     DESCRIPTION       : Retrieve the Type Code for Given Electronic document Refm Value
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 15-Aug-2012 
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
 
  SELECT @Ac_Type_CODE = R.Type_CODE
    FROM RESF_Y1 R
   WHERE R.Process_ID = @Ac_Process_ID
     AND R.Table_ID = @Ac_Table_ID
     AND R.TableSub_ID = @Ac_TableSub_ID
     AND R.Reason_CODE = @Ac_Reason_CODE;
 END; --END OF RESF_RETRIEVE_S20


GO
