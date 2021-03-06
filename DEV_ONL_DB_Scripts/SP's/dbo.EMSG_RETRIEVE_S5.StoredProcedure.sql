/****** Object:  StoredProcedure [dbo].[EMSG_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EMSG_RETRIEVE_S5]
AS
 /*                                                             
  *     Procedure Name    : EMSG_RETRIEVE_S5                    
  *     Description       : Retrieves All Error Code and Description From Error Message Table
  *     Developed By      : IMP Team                            
  *     Developed On      : 03-AUG-2011                         
  *     Modified By       :                                     
  *     Modified On       :                                     
  *     Version No        : 1                                   
 */
 BEGIN
  SELECT E.Error_CODE,
         E.DescriptionError_TEXT
    FROM EMSG_Y1 E
   ORDER BY E.Error_CODE;
 END; --End of EMSG_RETRIEVE_S5                                  

GO
