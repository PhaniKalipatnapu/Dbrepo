/****** Object:  StoredProcedure [dbo].[CTHB_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_UPDATE_S2] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ad_Transaction_DATE       DATE,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_SignedOnWorker_ID      CHAR(30)
 )
AS
 /*    
  *     PROCEDURE NAME    : CTHB_UPDATE_S2    
  *     DESCRIPTION       : Update Case ID for a Unique ID generated by the system to indicate the record, State FIPS for the state and Transaction DATE.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Li_Zero_NUMB         SMALLINT = 0;

  UPDATE CTHB_Y1
     SET Case_IDNO = ISNULL(@An_Case_IDNO, @Li_Zero_NUMB),
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID
   WHERE TransHeader_IDNO = @An_TransHeader_IDNO
     AND Transaction_DATE = @Ad_Transaction_DATE
     AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND Case_IDNO = @Li_Zero_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END --End of CTHB_UPDATE_S2

GO
