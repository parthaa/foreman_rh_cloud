import { inventoryUrl, getInventoryDocsUrl } from '../ForemanInventoryHelpers';

describe('ForemanInventoryUpload helpers', () => {
  it('should return inventory Url', () => {
    expect(inventoryUrl('test_path')).toBe('/foreman_inventory_upload/test_path');
  });

  it('should return inventory docs url', () => {
    expect(getInventoryDocsUrl()).toBe(
      'https://access.redhat.com/documentation/en-us/red_hat_satellite/6.11/html/managing_hosts/Synchronizing_Host_Information_Between_Satellite_Server_and_the_Red_Hat_Hybrid_Cloud_Console_managing-hosts'
    );
  });
});
