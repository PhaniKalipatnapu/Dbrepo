/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S21] (
 @An_Case_IDNO           NUMERIC(6, 0),
 @Ac_File_ID             CHAR(10) OUTPUT,
 @An_OrderSeq_NUMB       NUMERIC(2, 0) OUTPUT,
 @Ad_OrderIssued_DATE    DATE OUTPUT,
 @Ad_OrderEffective_DATE DATE OUTPUT,
 @Ad_OrderEnd_DATE       DATE OUTPUT
 )
AS
 /*                                                                                   
 *     PROCEDURE NAME    : SORD_RETRIEVE_S21                                          
  *     DESCRIPTION       : Retrieve Support Order Details for a given Case.  
  *     DEVELOPED BY      : IMP Team                                                
  *     DEVELOPED ON      : 02-AUG-2011                                               
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
 */
 BEGIN
  SELECT @An_OrderSeq_NUMB = NULL,
         @Ac_File_ID = NULL,
         @Ad_OrderIssued_DATE = NULL,
         @Ad_OrderEffective_DATE = NULL,
         @Ad_OrderEnd_DATE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_OrderSeq_NUMB = b.OrderSeq_NUMB,
         @Ac_File_ID = b.File_ID,
         @Ad_OrderIssued_DATE = b.OrderIssued_DATE,
         @Ad_OrderEffective_DATE = b.OrderEffective_DATE,
         @Ad_OrderEnd_DATE = b.OrderEnd_DATE
    FROM CASE_Y1 a
         JOIN SORD_Y1 b
          ON b.Case_IDNO = a.Case_IDNO
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END; --End of SORD_RETRIEVE_S21        

GO
