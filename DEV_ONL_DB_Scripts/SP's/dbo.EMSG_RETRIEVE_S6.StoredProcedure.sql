/****** Object:  StoredProcedure [dbo].[EMSG_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMSG_RETRIEVE_S6] (
 @Ac_TypeError_CODE CHAR(1)
 )
AS
 /*                                                                                         
  *     Procedure Name    : EMSG_RETRIEVE_S6                                                
  *     Description       : Retrieves Error Code and Description for the given Error Type    
  *     Developed By      : IMP Team                                                        
  *     Developed On      : 02-AUG-2011                                                     
  *     Modified By       :                                                                 
  *     Modified On       :                                                                 
  *     Version No        : 1                                                               
 */
 BEGIN
  SELECT E.Error_CODE,
         E.DescriptionError_TEXT
    FROM EMSG_Y1 E
   WHERE E.TypeError_CODE = @Ac_TypeError_CODE
   ORDER BY E.Error_CODE;
 END; --End of EMSG_RETRIEVE_S6                                                              


GO
