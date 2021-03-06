/****** Object:  StoredProcedure [dbo].[APDI_DELETE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDI_DELETE_S1](
 @An_Application_IDNO  NUMERIC(15) 
 )
AS
 /*                                                                                                                                                                               
  *     PROCEDURE NAME    : APDI_DELETE_S1                                                                                                                                         
  *     DESCRIPTION       : Deletes the insurance details once the member has no insurance.
  *     DEVELOPED BY      : IMP Team                                                                                                                                            
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
 BEGIN
  DECLARE @Li_RowsAffected_NUMB INT;

  DELETE FROM APDI_Y1
   WHERE Application_IDNO = @An_Application_IDNO;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of APDI_DELETE_S1

GO
